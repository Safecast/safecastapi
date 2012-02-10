jQuery -> 
  window.GoogleMap = 
      
    performGeocode: (value) ->
      geocoder = new google.maps.Geocoder()
      geocoder.geocode {'address': value}, (results, status) ->
        if (status == window.google.maps.GeocoderStatus.OK)
          map.setCenter(results[0].geometry.location);
          marker = new google.maps.Marker
                            map: map, 
                            position: results[0].geometry.location
          $('#latitude').val(results[0].geometry.location.Pa)
          $('#longitude').val(results[0].geometry.location.Qa)

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