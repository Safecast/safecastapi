App.Views.NewMeasurement = App.Views.App.extend
  
  initialize: ->
    @model.bind('change', @render, @)
    @model.bind('error', @alertError, @)
    
    if window.hasOwnProperty('google')
      latlng = new window.google.maps.LatLng(37.7607226, 140.47335610000005)
      window.myOptions =
        zoom: 17,
        center: latlng,
        navigationControlOptions: {style: window.google.maps.NavigationControlStyle.SMALL},
        mapTypeId: window.google.maps.MapTypeId.ROADMAP
    return @
  
  setUnit: (e) ->
    $('#unit').val($(e.target).data('value'))

  events:
    'submit #submission' : 'manifest'
    'click #location'    : 'showMap'
    'keydown #location'  : 'geocodeSearch'
    'click .gps'         : 'geocodeSearch'
    'click .unit'        : 'setUnit'
  
  alertError: ->
    $('form#submission').effect('shake', {
      distance: 10
    }, 100)

  showMap: (e)->
    @.$('#map_canvas').show()
    if window.hasOwnProperty('google')
      window.google.maps.event.trigger(map, 'resize')
      @geocodeSearch(e)

  performGeocode: (model, value)->
    if window.hasOwnProperty('google')
      geocoder = new window.google.maps.Geocoder()
      geocoder.geocode {'address': value}, (results, status) ->
        if (status == window.google.maps.GeocoderStatus.OK)
          map.setCenter(results[0].geometry.location);
          marker = new window.google.maps.Marker
                            map: map, 
                            position: results[0].geometry.location
          $('#latitude').val(results[0].geometry.location.Pa)
          $('#longitude').val(results[0].geometry.location.Qa)

  geocodeSearch: (e)->
    if(e.hasOwnProperty('which'))
      if e.which == 13
        @performGeocode(@model, $('#location').val())
        e.preventDefault()
    return unless $.trim($('#location').val()) != ''
    countdown = (model, value) =>
      return =>
        if $('#location').val() == value
          @performGeocode(model, value)
    setTimeout =>
      setTimeout(countdown(@model, $('#location').val()) , 1000)
    , 5

  
  templatePath: ->
    return 'my/measurements/show' if(@model.get('saving')?)
    return 'my/measurements/manifest' if(@model.get('value') > 0)
    'my/measurements/new'

  render: ->
    @.$el.html(@template())
    @.$('#level').select().focus()
    return @
  
  manifest: ->
    document.location.href = '/my/measurements/manifest?' + $('form#submission').serialize()
    false