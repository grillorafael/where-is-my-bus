class Map
    constructor: ->
        mapOptions =
            center: new google.maps.LatLng(-22.9024059, -43.1134247)
            zoom: 15
            mapTypeId: google.maps.MapTypeId.ROADMAP

        @markers = {}
        @map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

    insertPin: (id, latitude, longitude, opts = null) ->
        if @markers[id]
            @removeMarker @markers[id]

        position = new google.maps.LatLng latitude, longitude
        options = $.extend {}, {position: position, map: @map}, opts
        marker = new google.maps.Marker options
        @markers[id] = marker

    centerUserPosition: (zoom = 15) ->
        if navigator.geolocation
            navigator.geolocation.getCurrentPosition (position) =>
                myLatLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
                @map.setCenter myLatLng
                @map.setZoom zoom
        else
            console.log "Not supported"

    removeMarker: (marker) ->
        marker.setMap null

    clearMarkers: ->
        while @markers.length > 0
            marker = @markers.pop()
            marker.setMap null

# This should be reviewed
# The Map Object is in the following format:
# {
#     id: 1, The id of the current Object {Must be unique}
#     label: "47", The label of the object
#     type: "bus", The type of the object
#     latitude: -10.01203, Object Position
#     longitude: -22.2323 Object Position
# }
class Server
    constructor: (map, verbose = false) ->
        @verbose = verbose
        @map = map
        @ws = new WebSocket("ws://localhost:5000")
        @ws.onmessage = @onMessage;
        @ws.onClose = @onClose;
        @ws.onopen = @onOpen;

    onMessage: (msg) =>
        @console "Message Received" + msg.data
        data = JSON.parse msg.data

        @map.insertPin data.id, data.latitude, data.longitude
    onClose: (event) =>
        @console "Connection Closed"
    onOpen: (msg) =>
        @console "Connection Stablished"
    console: (msg) =>
        if @verbose
            date = new Date()
            dateText = "[" + date.getFullYear() + "-" + ((if date.getMonth() + 1 > 9 then date.getMonth() + 1 else "0" + date.getMonth() + 1)) + "-" + ((if date.getDate() > 9 then date.getDate() else "0" + date.getDate())) + " " + ((if date.getHours() > 9 then date.getHours() else "0" + date.getHours())) + ":" + ((if date.getMinutes() > 9 then date.getMinutes() else "0" + date.getMinutes())) + ":" + ((if date.getSeconds() > 9 then date.getSeconds() else "0" + date.getSeconds())) + "]"
            console.log dateText + " " + msg

# To access via Chrome Javascript Console
map = server = null
$ ->
    map = new Map()
    server = new Server(map, true)










