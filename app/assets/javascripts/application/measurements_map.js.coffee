maps = window.google.maps

$ ->
  window.MeasurementsMap =
    addMeasurementsAndCenter: (measurements) ->
      bounds = new maps.LatLngBounds()
      for measurement in measurements
        position = new maps.LatLng(measurement.lat, measurement.lng)
        icon = new maps.MarkerImage(
          MeasurementsMap.iconForMeasurement(measurement.cpm),
          new maps.Size(11, 11),
          new maps.Point(0,0),
          new maps.Point(6, 6)) if measurement.cpm
        new maps.Marker(
          map: map,
          position: position,
          icon: icon)
        bounds.extend(position)
      map.setCenter(bounds.getCenter(), map.fitBounds(bounds))

    iconForMeasurement: (cpm) ->
      if cpm >= 1050 then assets['markers/grey.png']
      else if cpm >= 680 then assets['markers/darkRed.png']
      else if cpm >= 420 then assets['markers/red.png']
      else if cpm >= 350 then assets['markers/darkOrange.png']
      else if cpm >= 280 then assets['markers/orange.png']
      else if cpm >= 175 then assets['markers/yellow.png']
      else if cpm >= 105 then assets['markers/lightGreen.png']
      else if cpm >= 70 then assets['markers/green.png']
      else if cpm >= 35 then assets['markers/midgreen.png']
      else assets['markers/white.png']
