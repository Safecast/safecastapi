jQuery ->
  return unless window.hasOwnProperty('BgeigieImport')
  advanceMapLoader = (percent)->
    $('#map-loading .bar').css('width', "#{percent}%")

  if !$('div#done').hasClass('bar-success')
    head_interval = setInterval ->
      $.get(BgeigieImport.url, {partial: 'head'}, 'html').success (data)->
        if $('div#done').hasClass('bar-success')
          clearInterval(head_interval)
        else
          $('#head').html(data)
    , 5000

  window.loadMap = ->
    return if $.trim($('#map_canvas').html()) != ''
    $('#map-loading').show()
    percent = 20
    advanceMapLoader(percent)
    loader_interval = setInterval ->
      percent = percent + 1
      advanceMapLoader(percent)
      clearInterval(loader_interval) if percent == 50
    , 1000
    $.get("#{BgeigieImport.map_url}.json", {}, 'json').success (data)->
      $('#show-map').show()
      clearInterval(loader_interval)
      advanceMapLoader(60)
      MeasurementsMap.initialize($("#map_canvas"))
      MeasurementsMap.addMeasurementsAndCenter(data)
      google.maps.event.addListenerOnce map, 'idle', ->
        advanceMapLoader(100)
        google.maps.event.trigger(map, 'resize');
        setTimeout ->
          $('#map-loading').hide()
        , 500

  $(loadMap)
