require 'json'
require 'websocket/driver'
require_relative 'websocket_client'

# One chat user for /chat/socket. Events from the server go to a queue, read with next_event.
class ChatClient
  def initialize(base_url, room)
    @ws = WebSocketClient.new(base_url, "/chat/socket?room=#{room}")
    @driver = WebSocket::Driver.client(@ws)
    @events = Queue.new
    @lock = Mutex.new
    @driver.on(:message) { |event| @events << JSON.parse(event.data) }
    @lock.synchronize { @driver.start }
    @reader = Thread.new do
      loop do
        data = @ws.socket.readpartial(4096)
        @lock.synchronize { @driver.parse(data) }
      end
    rescue IOError, SystemCallError
      # Closed.
    end
  end

  def send_json(message)
    @lock.synchronize { @driver.text(JSON.generate(message)) }
  end

  # Joins and waits for the server's "<name> joined" notice.
  def join(name)
    send_json(type: 'join', name: name)
    next_event
  end

  def say(text)
    send_json(type: 'message', text: text)
  end

  # The next event, or nil after `timeout` seconds.
  def next_event(timeout = 5)
    @events.pop(timeout: timeout)
  end

  def close
    @ws.socket.close
    @reader.join(1)
  end
end
