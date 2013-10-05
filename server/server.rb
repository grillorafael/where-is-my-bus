#require 'pry'
require 'em-websocket'

EventMachine::WebSocket.start(host: "127.0.0.1", port: 5000) do |ws|
  ws.onopen do |handshake|
    puts "WebSocket opened #{{
      :path => handshake.path,
      :query => handshake.query,
      :origin => handshake.origin,
    }}"
  end

  ws.onmessage do |msg|
    ws.send msg
  end

  ws.onclose do
    puts "WebSocket closed"
  end

  ws.onerror do |e|
    puts "Error: #{e.message}"
  end
end