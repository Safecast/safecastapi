jQuery ->
  if window.hasOwnProperty('google') && $('#map_canvas').length > 0
    latlng = new window.google.maps.LatLng($('#latitude').val(), $('#longitude').val())
    myOptions =
      zoom: 17,
      center: latlng,
      navigationControlOptions: {style: window.google.maps.NavigationControlStyle.SMALL},
      mapTypeId: window.google.maps.MapTypeId.ROADMAP
    window.map = new window.google.maps.Map(document.getElementById("map_canvas"), myOptions)
    centerMap = () ->
      center = map.getCenter()
      $('#latitude').val(center.lat())
      $('#longitude').val(center.lng())
    google.maps.event.addListener map, 'center_changed', centerMap
    centerMap()
    google.maps.event.addDomListener $('.map-crosshair')[0], 'dblclick', () ->
        map.setZoom(map.getZoom() + 1)
  
  # focus
  $(document).delegate '.field input', 'click', ->
    $(this).parents('.field:first').addClass('focus')

  $(document).delegate '.field input', 'blur', ->
    $(this).parents('.field:first').removeClass('focus')

  # unit selector
  $(document).delegate '.units li', 'click', ->
    $(this).siblings('li').removeClass('selected')
    $(this).addClass('selected')
    $('#unit').val($(this).data('value'))
    return false
  
  $('input, textarea').on 'click', ->
    $(this).select()
  
  $('#location').on 'click', (e) ->
    $('#map_canvas').show()
    if window.hasOwnProperty('google')
      google.maps.event.trigger(map, 'resize'); 
  
  $('#location').on 'keydown', (e) ->
    GoogleMap.geocodeSearch(e)