maps = window.google.maps

$ ->
  return if $("form#submission").length is 0

  # handle map changes
  GoogleMap.initialize(
    $('#map_canvas')
    $('#latitude').val()
    $('#longitude').val()
    parseInt($('#zoomlevel').val() or 17))
  centerMap = ->
    center = map.getCenter()
    $('#latitude').val(center.lat())
    $('#longitude').val(center.lng())
  maps.event.addListener map, 'center_changed', centerMap
  centerMap()
  if $('.map-crosshair').length > 0
    maps.event.addDomListener $('.map-crosshair')[0], 'dblclick', () ->
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
      maps.event.trigger(map, 'resize'); 
  
  $('#location').on 'keydown', (e) ->
    GoogleMap.geocodeSearch(e)