class Server
  constructor: (verbose = false) ->
    @verbose = verbose
    getConfigInfo (data) =>
      @ws = new WebSocket("ws://"+data.server.js_host+":"+data.server.port)
      @ws.onmessage = @onMessage
      @ws.onClose = @onClose
      @ws.onopen = @onOpen
      @ws.onerror = @onError
  sendMessage: (data) ->
    string_data = JSON.stringify(data)
    @ws.send string_data
    @console string_data
  onMessage: (msg) =>
    @console "Message Received" + msg.data
  onClose: (event) =>
    @console "Connection Closed"
  onOpen: (msg) =>
    @console "Connection Stablished"
  onError: (msg) =>
    @console "An Error Occoured"
  console: (msg) =>
    if @verbose
      date_text = currentTimeStampLabel()
      console.log date_text + " " + msg