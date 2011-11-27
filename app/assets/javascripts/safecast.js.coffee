jQuery ->
  window.Measurement = Backbone.Model.extend
    defaults:
      value: '000'
    
    valid: ->
      !@validate(@attributes)
    
    url: ->
      return "/api/measurements/#{@id}" if @id
      "/api/measurements"
    
    validate: (attrs) ->
      errors = []
      console.log(attrs)
      if $.trim(attrs.value) == ''
        errors.push('Value Required')

      if parseInt(attrs.value) == 0
        errors.push('Value must be greater than 0')
        
      if errors.length > 0
        return errors
  
  window.AppView = Backbone.View.extend
    el: $("#page"),

    render: ->
      $(this.el).html("Welcome")
  
  window.MeasurementView = Backbone.View.extend
    el: $("#page"),
    
    template: (path)->
      path = @templatePath() unless path
      Mustache.to_html(Templates[path], @model.toJSON())
    
    initialize: ->
      @model.bind('change', @render, @)
      @model.bind('error', @alertError, @)

  window.NewMeasurementView = MeasurementView.extend
    
    events: {
      'submit #submission' : 'manifest',
      'submit #manifest'   : 'create'
    }
    
    alertError: (model, errors)->
      alert(errors)
    
    templatePath: ->
      return 'measurements/show' if(@model.get('saving')?)
      return 'measurements/manifest' if(@model.get('value') > 0)
      'measurements/new'
    
    render: ->
      $(@el).html(@template())
      @.$('#level').select().focus()
      return @
    
    manifest: ->
      @model.set({value: $('#level').val()})
      false
    
    create: ->
      # @model.set {value: $('#level').val(), saving: true}
      @model.save {value: $('#level').val(), saving: true},
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
      new NewMeasurementView({model: measurement}).render()
    
    show: (id) ->
      new ShowMeasurementView({model: App.current_measurement}).render()