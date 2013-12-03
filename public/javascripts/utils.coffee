

gLatLng = (lat, lng) ->
  return new google.maps.LatLng lat, lng

getConfigInfo = (callback) ->
  $.getJSON "/config.json", (data) =>
    data = if data.env == "development" then data.development else data.production
    callback(data)

currentTimeStampLabel = ->
  date = new Date()
  date_text = "[" + date.getFullYear() + "-" + ((if date.getMonth() + 1 > 9 then date.getMonth() + 1 else "0" + date.getMonth() + 1)) + "-" + ((if date.getDate() > 9 then date.getDate() else "0" + date.getDate())) + " " + ((if date.getHours() > 9 then date.getHours() else "0" + date.getHours())) + ":" + ((if date.getMinutes() > 9 then date.getMinutes() else "0" + date.getMinutes())) + ":" + ((if date.getSeconds() > 9 then date.getSeconds() else "0" + date.getSeconds())) + "]"
  date_text