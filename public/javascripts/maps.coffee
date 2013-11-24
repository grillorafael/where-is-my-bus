class Resource
  imagePath = "/images/"
  constructor: (id, type, label, latitude, longitude, info, marker = null) ->
    @id = id
    @type = type
    @label = label
    @latitude = latitude
    @longitude = longitude
    @marker = marker

    @info = info
  setMarker: (opts) ->
    @marker = new google.maps.Marker opts

    @infowindow = new google.maps.InfoWindow
      content: @dialog()
    google.maps.event.addListener @marker, 'click', =>
      @infowindow.open opts.map, @marker
  dialog: ->
    return "<div id='content'><h1>#{@label} (#{@type}) <button id='resource_#{@id}' data-id='#{@id}' class='btn btn-default follow-resource'>Follow</button></h1><div id='resource-content'>#{@info}</div></div>"
  icon: ->
    icons =
      bus: "#{imagePath}bus.png"
      plane: "#{imagePath}plane.png"
    icons[@type]


class Map
  constructor: ->
    mapOptions =
      center: gLatLng -22.9024059, -43.1134247
      zoom: 15
      mapTypeId: google.maps.MapTypeId.ROADMAP
    @resources = {}
    @map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
  insertPin: (resource) ->
    if @resources[resource.id]
      @updateMarker resource
    position = gLatLng resource.latitude, resource.longitude
    options = {position: position, map: @map, icon: resource.icon()}
    resource.setMarker options
    @resources[resource.id] = resource
  centerUserPosition: (zoom = 15) ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition (position) =>
        myLatLng = gLatLng position.coords.latitude, position.coords.longitude
        @map.setCenter myLatLng
        @map.setZoom zoom
    else
        console.log "Not supported"
  centerResourcePosition: (resource) ->
    @map.setCenter resource.marker.getPosition()
  updateMarker: (resource) ->
    resource = @resources[resource.id]
    resource.marker.setPosition gLatLng resource.latitude, resource.longitude
  removeMarker: (resource) ->
    resource.marker.setMap null
    resource.marker = null
  clearMarkers: ->
    while @resources.length > 0
      resource = @resources.pop()
      resource.marker.setMap null

class MapServer
  constructor: (map) ->
    @map = map
    @server = new Server(true)
    @server.onMessage = @onMessage

  onMessage: (msg) =>
    @server.console "Message Received" + msg.data
    data = JSON.parse msg.data
    resource = new Resource(data.id, data.type, data.label, data.latitude, data.longitude, data.info)
    @map.insertPin resource

class Sidebar
  constructor: (map) ->
    @map = map
    $('#toggle').click @toggle
  resourceUpdate: ->
    resources_list = $('#resources')
    resources_list.html ""
    for resource_id of @map.resources
      resource = @map.resources[resource_id]
      resources_list.append "<li class='resource'><a href='#' data-id='#{resource.id}' class='resource-item'><img src='#{resource.icon()}' class='icon'/><div class='label'>#{resource.label}</div></a></li>"
    @addResourceClickListener()
  addResourceClickListener: ->
    $('.resource-item').click (e) =>
      resource_id = $(e.target).data 'id'
      @map.centerResourcePosition @map.resources[resource_id]
  toggle: ->
    sb = $('#sidebar')
    tg = $('#toggle')
    if sb.css('right') is '0px'
      sb.css('right', '-250px')
      tg.html '<'
    else
      sb.css('right', '0px')
      tg.html '>'

# To access via Chrome Javascript Console
sidebar = map = null
$ ->
    map = new Map()
    sidebar = new Sidebar map
    mapServer = new MapServer map








