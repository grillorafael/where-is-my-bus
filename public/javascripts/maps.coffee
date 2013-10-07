class Resource
    imagePath = "/images/"
    constructor: (id, type, label, latitude, longitude, marker = null) ->
        @id = id
        @type = type
        @label = label
        @latitude = latitude
        @longitude = longitude
        @marker = marker
    icon: ->
        icons =
            bus: "#{imagePath}bus.png"
        icons[@type]


class Map
    constructor: ->
        mapOptions =
            center: new google.maps.LatLng(-22.9024059, -43.1134247)
            zoom: 15
            mapTypeId: google.maps.MapTypeId.ROADMAP

        @markers = {}
        @map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

    insertPin: (resource) ->
        if @markers[resource.id]
            @removeMarker @markers[resource.id]

        position = new google.maps.LatLng resource.latitude, resource.longitude
        options = {position: position, map: @map, icon: resource.icon()}
        resource.marker = new google.maps.Marker options
        @markers[resource.id] = resource

    centerUserPosition: (zoom = 15) ->
        if navigator.geolocation
            navigator.geolocation.getCurrentPosition (position) =>
                myLatLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
                @map.setCenter myLatLng
                @map.setZoom zoom
        else
            console.log "Not supported"

    removeMarker: (resource) ->
        resource.marker.setMap null
        resource.marker = null

    clearMarkers: ->
        while @markers.length > 0
            resource = @markers.pop()
            resource.marker.setMap null

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
        @ws = new WebSocket("ws://127.0.0.1:5000")
        @ws.onmessage = @onMessage
        @ws.onClose = @onClose
        @ws.onopen = @onOpen
        @ws.onerror = @onError

    onMessage: (msg) =>
        @console "Message Received" + msg.data
        data = JSON.parse msg.data
        resource = new Resource(data.id, data.type, data.label, data.latitude, data.longitude)
        @map.insertPin resource
    onClose: (event) =>
        @console "Connection Closed"
    onOpen: (msg) =>
        @console "Connection Stablished"
    onError: (msg) =>
        @console "An Error Occoured"
    console: (msg) =>
        if @verbose
            date = new Date()
            dateText = "[" + date.getFullYear() + "-" + ((if date.getMonth() + 1 > 9 then date.getMonth() + 1 else "0" + date.getMonth() + 1)) + "-" + ((if date.getDate() > 9 then date.getDate() else "0" + date.getDate())) + " " + ((if date.getHours() > 9 then date.getHours() else "0" + date.getHours())) + ":" + ((if date.getMinutes() > 9 then date.getMinutes() else "0" + date.getMinutes())) + ":" + ((if date.getSeconds() > 9 then date.getSeconds() else "0" + date.getSeconds())) + "]"
            console.log dateText + " " + msg

# To access via Chrome Javascript Console
map = server = null
$ ->
    map = new Map()
    server = new Server map, true
    #setTimeout (-> simulateBus -22.9033059, -43.12542000 ), 500


simulateBus = (lat, long) ->
    setTimeout (->
        simulateBus lat, long + 0.0003
    ), 1000

    server.ws.send(JSON.stringify(
      id: 2
      type: "bus"
      latitude: lat
      longitude: long
    ))









