maps = window.google.maps

$ -> 
  window.GoogleMap = 
    setCenter: (lat, lng) ->
      position = new maps.LatLng(lat, lng)
      map.setCenter position
  
    addPointsAndCenter: (points) ->
      bounds = new maps.LatLngBounds()
      for point in points
        position = new maps.LatLng(point.lat, point.lng)
        new maps.Marker(
          map: map, 
          position: position)
        bounds.extend(point.position)
      map.setCenter(bounds.getCenter(), map.fitBounds(bounds))

    performGeocode: (value) ->
      geocoder = new maps.Geocoder()
      geocoder.geocode {'address': value}, (results, status) ->
        if (status == maps.GeocoderStatus.OK)
          map.setCenter(results[0].geometry.location);
          $('#latitude').val(results[0].geometry.location.lat())
          $('#longitude').val(results[0].geometry.location.lng())

    geocodeSearch: (e) ->
      if(e.hasOwnProperty('which'))
        if e.which == 13
          @performGeocode($('#location').val())
          e.preventDefault()
      return unless $.trim($('#location').val()) != ''
      countdown = (value) =>
        return =>
          if $('#location').val() == value
            @performGeocode(value)
      setTimeout =>
        setTimeout(countdown($('#location').val()) , 1000)
      , 5
