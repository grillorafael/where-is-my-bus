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
    # client.name = assign_name(websocket.request["query"]["name"])
    # send_all "e" + client.name                   # Alert other clients.
    @clients[websocket] = client
    # websocket.send "n" + client.name             # Tell client what its assigned name is.
    # websocket.send "s" + client_names.join(",")  # Tell client who is in the room.
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