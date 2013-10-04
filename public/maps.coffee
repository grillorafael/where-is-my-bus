class Map
    constructor: ->
        mapOptions =
            center: new google.maps.LatLng(-22.9024059, -43.1134247)
            zoom: 15
            mapTypeId: google.maps.MapTypeId.ROADMAP

        @markers = []
        @map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

    insertPin: (latitude, longitude, opts = null) ->
        position = new google.maps.LatLng latitude, longitude
        options = $.extend {}, {position: position, map: @map}, opts
        console.log options
        marker = new google.maps.Marker options
        @markers.push marker

    centerUserPosition: (zoom = 15) ->
        if navigator.geolocation
            navigator.geolocation.getCurrentPosition (position) =>
                myLatLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
                @map.setCenter myLatLng
                @map.setZoom zoom
        else
            console.log "Not supported"

    clearMarkers: ->
        while @markers.length > 0
            marker = @markers.pop()
            marker.setMap null

initialize = ->
    @map = new Map()
    #@map.insertPin(-22.9024059, -43.1134247, {icon: "images/bus.png"})
    #map.centerUserPosition()

google.maps.event.addDomListener window, "load", initialize