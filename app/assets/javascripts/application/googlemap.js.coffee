google = window.google

jQuery -> 
  window.GoogleMap = 
    setCenter: (lat, lng) ->
      position = new window.google.maps.LatLng(lat, lng)
      map.setCenter position
  
    addPoints: (points) ->
      for point in points
        position = new google.maps.LatLng(point.lat, point.lng)
        image = 
          if point.cpm >= 1050 then 'markers/grey.png'
          else if point.cpm >= 680 then 'markers/darkRed.png'
          else if point.cpm >= 420 then 'markers/red.png'
          else if point.cpm >= 350 then 'markers/darkOrange.png'
          else if point.cpm >= 280 then 'markers/orange.png'
          else if point.cpm >= 175 then 'markers/yellow.png'
          else if point.cpm >= 105 then 'markers/lightGreen.png'
          else if point.cpm >= 70 then 'markers/green.png'
          else if point.cpm >= 35 then 'markers/midgreen.png'
          else 'markers/white.png'
        icon = new google.maps.MarkerImage(assets[image],
            new google.maps.Size(11, 11),
            new google.maps.Point(0,0),
            new google.maps.Point(6, 6));

        new google.maps.Marker(
          map: map, 
          position: position,
          icon: icon)

    fitPoints: (points) ->
      bounds = new window.google.maps.LatLngBounds()
      for point in points
        position = new window.google.maps.LatLng(point.lat, point.lng)
        bounds.extend(position)
      map.setCenter(bounds.getCenter(), map.fitBounds(bounds))
      
    performGeocode: (value) ->
      geocoder = new google.maps.Geocoder()
      geocoder.geocode {'address': value}, (results, status) ->
        if (status == window.google.maps.GeocoderStatus.OK)
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
