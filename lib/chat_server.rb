require 'json'
require 'socket'
require 'fileutils'
require 'websocket/driver'

# Chat server for /chat. Like WebSocketEcho, it takes over each connection from puma
# (full hijack) and reads it on its own thread.
#
# Puma runs several worker processes, and each browser can land on any of them. So every
# event goes through ChatRelay, which hands it to every process on the machine, the
# sender's included. Each process then sends it to its own connections in that room.
# Nothing is stored: a message only reaches the users who are in the room when it is sent.
#
# The relay only reaches processes on the same machine (one Heroku dyno, one Docker
# container). With more than one dyno or container, users on different ones don't see
# each other.
class ChatServer
  MAX_CONNECTIONS = 50
  MAX_NAME_LENGTH = 30
  MAX_TEXT_LENGTH = 500
  ROOM = /\A[A-Za-z0-9_-]{1,64}\z/
  PING_INTERVAL = 25 # seconds; keeps Heroku's router (55 s idle timeout) from closing the socket
  IDLE_TIMEOUT = 10 * 60 # seconds without a chat message from this user

  @connections = 0
  @rooms = Hash.new { |rooms, name| rooms[name] = [] } # connections of this process, per room
  @lock = Mutex.new

  class << self
    # Returns false when the process already has MAX_CONNECTIONS open.
    def start(env, room)
      return false unless reserve
      io = env['rack.hijack'].call
      Thread.new { new(env, io, room).run }
      true
    rescue StandardError
      release
      raise
    end

    def release
      @lock.synchronize { @connections -= 1 }
    end

    def add(room, connection)
      @lock.synchronize { @rooms[room] << connection }
    end

    def remove(room, connection)
      @lock.synchronize do
        @rooms[room].delete(connection)
        @rooms.delete(room) if @rooms[room].empty?
      end
    end

    def publish(room, event)
      ChatRelay.publish(JSON.generate([room, event]))
    end

    # Called by ChatRelay for every event, from any process.
    def deliver(data)
      room, event = JSON.parse(data)
      connections = @lock.synchronize { @rooms.fetch(room, []).dup }
      json = JSON.generate(event)
      connections.each { |connection| connection.send_text(json) }
    end

    private

    def reserve
      @lock.synchronize do
        return false if @connections >= MAX_CONNECTIONS
        @connections += 1
      end
    end
  end

  attr_reader :env

  def initialize(env, io, room)
    @env = env
    @io = io
    @room = room
    @name = nil
    @last_message = now
    @lock = Mutex.new # the driver is used by this thread and by the relay thread
    @driver = WebSocket::Driver.rack(self, max_length: 4096)
    @driver.on(:message) { |event| receive(event.data) }
    @driver.on(:close) { @closed = true }
  end

  # Called by the driver to send bytes to the browser.
  def write(data)
    @io.write(data)
  rescue IOError, SystemCallError
    @closed = true
  end

  def send_text(json)
    @lock.synchronize { @driver.text(json) unless @closed || @closing }
  end

  def run
    @lock.synchronize { @driver.start }
    until @closed
      # After the server starts closing, wait a little for the browser's reply.
      if @io.wait_readable(@closing ? 2 : PING_INTERVAL)
        data = @io.readpartial(4096)
        @lock.synchronize { @driver.parse(data) }
      elsif @closing
        break
      elsif now - @last_message > IDLE_TIMEOUT
        @lock.synchronize { close("No messages for #{IDLE_TIMEOUT / 60} minutes") }
      else
        @lock.synchronize { @driver.ping }
      end
    end
  rescue EOFError, IOError, SystemCallError
    # The browser went away.
  ensure
    leave
    @io.close unless @io.closed?
    self.class.release
  end

  private

  # The browser sends {"type": "join", "name": "..."} once, then {"type": "message", "text": "..."}.
  def receive(data)
    message = JSON.parse(data)
    case message['type']
    when 'join' then join(clean(message['name'], MAX_NAME_LENGTH))
    when 'message' then say(clean(message['text'], MAX_TEXT_LENGTH))
    end
  rescue JSON::ParserError, TypeError
    # Not a chat message: ignore it.
  end

  def join(name)
    return if @name || name.empty?
    @name = name
    self.class.add(@room, self)
    self.class.publish(@room, type: 'notice', text: "#{@name} joined")
  end

  def say(text)
    return if @name.nil? || text.empty?
    @last_message = now
    self.class.publish(@room, type: 'message', author: @name, text: text)
  end

  def leave
    return unless @name
    self.class.remove(@room, self)
    self.class.publish(@room, type: 'notice', text: "#{@name} left")
  end

  # Text only (the browser shows it as text), on one line, without surrounding spaces, cut to `max`.
  def clean(value, max)
    value.is_a?(String) ? value.gsub(/[[:cntrl:]]/, ' ').strip[0, max].strip : ''
  end

  def close(reason)
    @closing = true
    @driver.close(reason, 1000)
  end

  def now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end

# Sends chat events between the puma workers of one machine, in memory. Each process
# listens on a Unix datagram socket in DIR (one file per process id). publish sends the
# event to every socket there, so every process gets it once, the sender's included.
module ChatRelay
  DIR = File.expand_path(ENV.fetch('CHAT_RELAY_DIR', 'tmp/chat'))
  BUFFER = 64 * 1024 # bigger than any event (a 500-character message is at most ~3 KB)

  @lock = Mutex.new

  class << self
    def publish(data)
      return ChatServer.deliver(data) unless listen
      Dir.glob(File.join(DIR, '*.sock')).each do |path|
        @sender.send(data, Socket::MSG_DONTWAIT, Socket.sockaddr_un(path))
      rescue Errno::ECONNREFUSED
        File.delete(path) # left by a process that is gone
      rescue Errno::ENOENT, Errno::EAGAIN, Errno::ENOBUFS
        # Gone in the meantime, or that process is too busy: it misses this event.
      end
    end

    private

    # Starts this process's listener the first time it is needed (after puma forks the workers).
    # Returns false if it can't (for example, DIR is too long for a socket path): then events
    # only reach this process.
    def listen
      @lock.synchronize do
        return true if @pid == Process.pid
        return false if @failed == Process.pid
        FileUtils.mkdir_p(DIR)
        path = File.join(DIR, "#{Process.pid}.sock")
        FileUtils.rm_f(path)
        inbox = Socket.new(:UNIX, :DGRAM)
        inbox.bind(Socket.sockaddr_un(path))
        inbox.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVBUF, BUFFER * 4)
        @sender = Socket.new(:UNIX, :DGRAM)
        @sender.setsockopt(Socket::SOL_SOCKET, Socket::SO_SNDBUF, BUFFER)
        at_exit { FileUtils.rm_f(path) }
        Thread.new do
          loop do
            data = inbox.recv(BUFFER)
            begin
              ChatServer.deliver(data)
            rescue StandardError
              # A bad event must not stop the relay.
            end
          end
        end
        @pid = Process.pid
        true
      rescue StandardError => e
        warn "Chat relay not started, chat events only reach this process: #{e.message}"
        @failed = Process.pid
        false
      end
    end
  end
end
