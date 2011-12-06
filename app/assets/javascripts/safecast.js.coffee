jQuery ->
  window.Measurement = Backbone.Model.extend
    defaults:
      value: '000'
      location_name: 'Fukushima, Japan'
      unit: 'cpm'
      latitude: 0
      longitude: 0
    
    valid: ->
      !@validate(@attributes)
    
    url: ->
      return "/api/measurements/#{@id}" if @id
      "/api/measurements"
    
    validate:
      unit:
        required: true
      value:
        type: 'number'
        required: true
        min: 0
      latitude:
        required: true
  
  window.AppView = Backbone.View.extend
    el: $("#page"),

    render: ->
      $(this.el).html("Welcome")
  
  window.MeasurementView = Backbone.View.extend
    el: $("#page"),
    
    template: (path) ->
      path = @templatePath() unless path
      Mustache.to_html(Templates[path], @model.toJSON())
    
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
      

  window.NewMeasurementView = MeasurementView.extend
    
    events:
      'submit #submission' : 'manifest'
      'submit #manifest'   : 'create'
      'click #location'    : 'showMap'
      'keydown #location'  : 'geocodeSearch'
      'click .gps'         : 'geocodeSearch'
      'click .unit'        : 'setUnit'
      
    setUnit: (e) ->
      @model.attributes.unit = $(e.target).data('value')
    
    alertError: (model, errors) ->
      errorMessages = []
      if errors.hasOwnProperty('status')
        errorResponse = JSON.parse(errors.responseText)
        for field of errorResponse
          errorMessages.push("#{field} #{errorResponse[field]}")
      else
        for field of errors
          if errors[field][0] == 'number'
            errorMessages.push("#{field} must be a number")
          else if errors[field][0] == 'required'
            errorMessages.push("#{field} is required")
      alert(errorMessages)
    
    showMap: (e)->
      @.$('#map_canvas').show()
      if window.hasOwnProperty('google')
        if window.map == undefined
          options = 
            zoom: 6
            mapTypeId: google.maps.MapTypeId.ROADMAP
          window.map = new google.maps.Map(document.getElementById("map_canvas"), options)
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
            model.set {
                value:  $('#level').val()
                location_name: $('#location').val()
                unit: model.get('unit')
                latitude: results[0].geometry.location.Pa
                longitude: results[0].geometry.location.Qa
              },
              silent: true
      
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
      return 'measurements/show' if(@model.get('saving')?)
      return 'measurements/manifest' if(@model.get('value') > 0)
      'measurements/new'
    
    render: ->
      $(@el).html(@template())
      @.$('#level').select().focus()
      return @
    
    manifest: ->
      @model.set
        value: $('#level').val()
        location_name: $('#location').val()
        latitude: @model.get('latitude')
        longitude: @model.get('longitude')
        unit: @model.get('unit')
        
      false
    
    create: ->
      @model.save {
        value: $('#level').val()
        location_name: $('#location').val()
        latitude: $('#latitude').val()
        longitude: $('#longitude').val()
        unit: $('#unit').val()
        saving: true
      },
      success: =>
        measurementsRouter.navigate("my/measurements/#{@model.id}", true)
      false
  
  window.ShowMeasurementView = MeasurementView.extend
    
    templatePath: ->
      'measurements/show'
  
    initialize: ->
      @model.bind('change', @render, @)
      
    render: ->
      $(@el).html(@template())
  
  window.HomeRouter = Backbone.Router.extend
    routes:
      "*actions": "show"

    show: ->
      appView.render()
  
  window.MeasurementsRouter = Backbone.Router.extend
    routes:
      "my/measurements/new": "new",
      "my/measurements/:id": "show"
    
    new: ->
      measurement = new Measurement()
      App.current_measurement = measurement
      if window.hasOwnProperty('newMeasurementView')
        newMeasurementView.model = measurement
        newMeasurementView.initialize()
      else
        window.newMeasurementView = new NewMeasurementView({model: measurement})
      newMeasurementView.render()
      if window.hasOwnProperty('map')
        window.map = new window.google.maps.Map(document.getElementById("map_canvas"), myOptions)
    
    show: (id) ->
      window.showMeasurementView = new ShowMeasurementView({model: App.current_measurement})
      showMeasurementView.render()