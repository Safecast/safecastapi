maps = window.google.maps

$ ->
  window.MeasurementsMap = _.extend GoogleMap, 
    addMeasurementsAndCenter: (measurements) ->
      bounds = new maps.LatLngBounds()
      for measurement in measurements
        position = new maps.LatLng(measurement.lat, measurement.lng)
        bounds.extend(position)
        icon = MeasurementsMap.iconForMeasurement(measurement.cpm) if measurement.cpm
        marker = new maps.Marker(map: map, position: position, icon: icon)
        do (measurement) ->
          maps.event.addListener marker, 'mouseover', ->
            $(".lat").text(measurement.lat)
            $(".lng").text(measurement.lat)
            $(".cpm").text(measurement.cpm) if measurement.cpm
      map.setCenter(bounds.getCenter(), map.fitBounds(bounds))

    iconForMeasurement: (cpm) ->
      image = 
        if cpm >= 1050 then 'markers/grey.png'
        else if cpm >= 680 then 'markers/darkRed.png'
        else if cpm >= 420 then 'markers/red.png'
        else if cpm >= 350 then 'markers/darkOrange.png'
        else if cpm >= 280 then 'markers/orange.png'
        else if cpm >= 175 then 'markers/yellow.png'
        else if cpm >= 105 then 'markers/lightGreen.png'
        else if cpm >= 70 then 'markers/green.png'
        else if cpm >= 35 then 'markers/midgreen.png'
        else 'markers/white.png'
      new maps.MarkerImage(
        assets[image],
        new maps.Size(11, 11),
        new maps.Point(0, 0),
        new maps.Point(6, 6))
