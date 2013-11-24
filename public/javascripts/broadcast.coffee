class Broadcast
  constructor: (interval = 1000) ->
    @server = new Server(true)
    @interval = interval
    @running = false
    @server.onMessage = @onMessage
    @server.console = @console
  start: ->
    if !@running
      @id = $(".id").val()
      @type = $(".type").val()
      @label = $(".b-label").val()
      @info = $(".info").val()
      @broadcasting()
  broadcasting: ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition (position) =>
        @server.sendMessage
          id: @id
          type: @type
          label: @label
          info: @info
          latitude: position.coords.latitude
          longitude: position.coords.longitude
        setTimeout (=>
          @broadcasting()
        ), @interval
    else
      console.log "Not supported"
  console: (msg) =>
    if @server.verbose
      date_text = currentTimeStampLabel()
      console_text = "#{date_text} #{msg}"
      $('#console-viewer ul').prepend("<li>#{console_text}</li>")
  onMessage: (msg) ->
    @console "Message Received" + msg.data

$ ->
  broadcast = new Broadcast()
  $("#broadcast").submit (e) ->
    e.preventDefault()
    broadcast.start()
    false
  $("#start-broadcasting").click =>
    broadcast.start()