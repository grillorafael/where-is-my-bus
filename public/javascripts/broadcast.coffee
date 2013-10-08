class Broadcast
  constructor: (verbose = false) ->
    @verbose = verbose
    $.getJSON "/config.json", (data) =>
      data = if data.env == "development" then data.development else data.production
      @ws = new WebSocket("ws://"+data.server.js_host+":"+data.server.port)
      @ws.onmessage = @onMessage
      @ws.onClose = @onClose
      @ws.onopen = @onOpen
      @ws.onerror = @onError
      @running = false
  start: ->
    if !@running
      @id = $(".id").val()
      @type = $(".type").val()
      @label = $(".b-label").val()
      @broadcasting()
  broadcasting: ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition (position) =>
        @ws.send(JSON.stringify(
          id: @id
          type: @type
          label: @label
          latitude: position.coords.latitude
          longitude: position.coords.longitude
        ))
        setTimeout (=>
          @broadcasting()
        ), 1000
    else
        console.log "Not supported"
  onMessage: (msg) =>
      @console "Message Received" + msg.data
  onClose: (event) =>
    @console "Connection Closed"
    @running = false
  onOpen: (msg) =>
    @console "Connection Stablished"
  onError: (msg) =>
    @console "An Error Occoured"
    @running = false
  console: (msg) =>
    if @verbose
        date = new Date()
        dateText = "[" + date.getFullYear() + "-" + ((if date.getMonth() + 1 > 9 then date.getMonth() + 1 else "0" + date.getMonth() + 1)) + "-" + ((if date.getDate() > 9 then date.getDate() else "0" + date.getDate())) + " " + ((if date.getHours() > 9 then date.getHours() else "0" + date.getHours())) + ":" + ((if date.getMinutes() > 9 then date.getMinutes() else "0" + date.getMinutes())) + ":" + ((if date.getSeconds() > 9 then date.getSeconds() else "0" + date.getSeconds())) + "]"
        $("#console-viewer ul").prepend "<li>" + dateText + " " + msg + "</li>"

$ ->
  broadcast = new Broadcast(true)
  $("#broadcast").submit (e) ->
    e.preventDefault()
    broadcast.start()
    false
  $("#start-broadcasting").click =>
    broadcast.start()