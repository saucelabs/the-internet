require 'socket'
require 'openssl'
require 'uri'

# A minimal WebSocket client over TCP (or TLS for https) for the echo server.
class EchoClient
  attr_reader :url, :socket

  def initialize(base_url)
    uri = URI(base_url)
    @url = "#{uri.scheme == 'https' ? 'wss' : 'ws'}://#{uri.host}:#{uri.port}/websocket/echo"
    @socket = TCPSocket.new(uri.host, uri.port)
    return unless uri.scheme == 'https'
    @socket = OpenSSL::SSL::SSLSocket.new(@socket).tap { |s| s.hostname = uri.host; s.sync_close = true; s.connect }
  end

  def write(data)
    @socket.write(data)
  end
end
