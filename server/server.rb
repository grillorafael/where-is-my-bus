require 'pry'
require 'em-websocket'
require './client'

class Server
  attr_accessor :clients

  def initialize (ip, port)
    @clients = {}
    @ip = ip
    @port = port
  end

  def start
    EventMachine::WebSocket.start(host: @ip, port: @port) do |websocket|
      websocket.onopen { add_client websocket }
      websocket.onmessage { |msg| handle_message websocket, msg }
      websocket.onclose { remove_client websocket }
    end
  end

  def add_client(websocket)
    client = Client.new websocket
    @clients[websocket] = client
  end

  def remove_client(websocket)
    client = @clients.delete websocket
  end

  def send_all(message, sender)
    @clients.select{|websocket, client| websocket != sender }.each do |websocket, client|
      websocket.send message
    end
  end

  def handle_message(websocket, message)
    send_all message, websocket
  end
end