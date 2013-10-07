class Client
  attr_accessor :websocket
  attr_accessor :name

  def initialize(websocket_arg)
    @websocket = websocket_arg
  end
end