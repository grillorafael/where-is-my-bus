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
    "<div id='content'><h1>#{@label} (#{@type}) <button id='resource_#{@id}' data-id='#{@id}' class='btn btn-default follow-resource'>Follow</button></h1><div id='resource-content'>#{@info}</div></div>"
  icon: ->
    icons =
      bus: "#{imagePath}bus.png"
      plane: "#{imagePath}plane.png"
      bicycle: "#{imagePath}bicycle.png"
    icons[@type]


class Map
  constructor: ->
    mapOptions =
      center: gLatLng -22.9024059, -43.1134247
      zoom: 15
      mapTypeId: google.maps.MapTypeId.ROADMAP
      streetViewControl: false
      mapTypeControl: false
    @observers = []
    @resources = {}
    @following_id = -1
    @map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
  addObserver: (observer) ->
    @observers.push observer
  notifyObservers: ->
    for observer in @observers
      observer.notify()
  getResourceIds: ->
    resource_ids = []
    for resource_id of @resources
      resource_ids.push resource_id
    resource_ids
  insertPin: (resource) ->
    if @resources[resource.id]
      @resources[resource.id].latitude = resource.latitude
      @resources[resource.id].longitude = resource.longitude
      @updateMarker resource.id
    else
      position = gLatLng resource.latitude, resource.longitude
      options = {position: position, map: @map, icon: resource.icon()}
      resource.setMarker options

      # Tricky but work
      google.maps.event.addListener resource.infowindow, 'domready', =>
        $('.follow-resource').click (evt) =>
          resource_id = $(evt.target).data 'id'
          @follow resource_id

      @resources[resource.id] = resource
    @notifyObservers()
    if Number(resource.id) == Number(@following_id)
      @centerResourcePosition resource.id
  centerUserPosition: (zoom = 15) ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition (position) =>
        myLatLng = gLatLng position.coords.latitude, position.coords.longitude
        @map.setCenter myLatLng
        @map.setZoom zoom
    else
        console.log "Not supported"
  centerResourcePosition: (resource_id) ->
    resource = @resources[resource_id]
    @map.setCenter(gLatLng(resource.latitude, resource.longitude)) if resource
  updateMarker: (resource_id) ->
    resource = @resources[resource_id]
    resource.marker.setPosition(gLatLng(resource.latitude, resource.longitude))
  removeMarker: (resource) ->
    resource.marker.setMap null
    resource.marker = null
  follow: (resource_id) ->
    @following_id = resource_id
  unfollow: ->
    @following_id = -1
  clearMarkers: ->
    while @resources.length > 0
      resource = @resources.pop()
      resource.marker.setMap null

class MapServer
  constructor: (map) ->
    @map = map
    @server = new Server()
    @server.onMessage = @onMessage
  onMessage: (msg) =>
    @server.console "Message Received" + msg.data
    data = JSON.parse msg.data
    resource = new Resource(data.id, data.type, data.label, data.latitude, data.longitude, data.info)
    @map.insertPin resource

class Sidebar
  constructor: (map) ->
    @map = map
    @resources = []
    $('#toggle').click @toggle
  notify: ->
    @resourceUpdate()
  resourceUpdate: ->
    remove_from_list = $(@resources).not(@map.getResourceIds()).toArray()
    add_to_list = $(@map.getResourceIds()).not(@resources).toArray()

    resources_list = $('#resources')

    for remove_id of remove_from_list
      resource_id = remove_from_list[remove_id]
      $(".resource_#{resource_id}").remove()
    for add_to_list_id of add_to_list
      resource_id = add_to_list[add_to_list_id]
      @resources.push resource_id
      resource = @map.resources[resource_id]
      resources_list.append "<li class='resource'><a href='#' data-id='#{resource.id}' class='resource-item resource_#{resource.id}'><img src='#{resource.icon()}' class='icon'/><div>#{resource.label}</div></a></li>"

    if @map.following_id != -1
      resource = @map.resources[@map.following_id]
      if $('.resource.following').length == 0
        resources_list.prepend "<li class='resource following'><a href='#' data-id='#{resource.id}' class='resource-item'><img src='#{resource.icon()}' class='icon'/><div>#{resource.label}</div></a></li>"
      else if Number($('.resource.following a').data('id')) != Number(resource.id)
        $('.resource.following').remove()
        resources_list.prepend "<li class='resource following'><a href='#' data-id='#{resource.id}' class='resource-item'><img src='#{resource.icon()}' class='icon'/><div>#{resource.label}</div></a></li>"
    else
      $('.resource.following').remove()

    @addResourceClickListener()
  addResourceClickListener: ->
    $('.resource-item').click (e) =>
      resource_id = $(e.target).data 'id'
      @map.centerResourcePosition resource_id
    $('.following .resource-item').click =>
      @map.unfollow()
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
    map.addObserver sidebar








