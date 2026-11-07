require 'websocket/driver'

# WebSocket echo server for /websocket. Takes over the connection from puma (full hijack)
# and reads it on its own thread, so an open socket doesn't hold a puma thread.
# Limits keep it cheap: few connections per process, short messages, and the server
# closes a connection that stays quiet.
class WebSocketEcho
  MAX_CONNECTIONS = 50
  MAX_MESSAGE_LENGTH = 1000
  MAX_MESSAGES = 100
  IDLE_TIMEOUT = 30 # seconds; below Heroku's 55 s router timeout

  @connections = 0
  @lock = Mutex.new

  class << self
    # Returns false when the process already has MAX_CONNECTIONS open.
    def start(env)
      return false unless reserve
      io = env['rack.hijack'].call
      Thread.new { new(env, io).run }
      true
    rescue StandardError
      release
      raise
    end

    def release
      @lock.synchronize { @connections -= 1 }
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

  def initialize(env, io)
    @env = env
    @io = io
    @messages = 0
    @driver = WebSocket::Driver.rack(self, max_length: MAX_MESSAGE_LENGTH)
    @driver.on(:open) { @driver.text('Connected. Send a message and the server sends it back.') }
    @driver.on(:message) { |event| echo(event.data) }
    @driver.on(:close) { @closed = true }
  end

  # Called by the driver to send bytes to the browser.
  def write(data)
    @io.write(data)
  rescue IOError, SystemCallError
    @closed = true
  end

  def run
    @driver.start
    until @closed
      # After the server starts closing, wait a little for the browser's reply.
      if @io.wait_readable(@closing ? 2 : IDLE_TIMEOUT)
        @driver.parse(@io.readpartial(4096))
      elsif @closing
        break
      else
        close("No messages for #{IDLE_TIMEOUT} seconds")
      end
    end
  rescue EOFError, IOError, SystemCallError
    # The browser went away.
  ensure
    @io.close unless @io.closed?
    self.class.release
  end

  private

  # Text comes back as "Echo: <text>", binary data as is.
  def echo(data)
    @messages += 1
    data.is_a?(String) ? @driver.text("Echo: #{data}") : @driver.binary(data)
    close("Message limit (#{MAX_MESSAGES}) reached") if @messages >= MAX_MESSAGES
  end

  def close(reason)
    @closing = true
    @driver.close(reason, 1000)
  end
end
