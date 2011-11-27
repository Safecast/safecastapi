jQuery ->
  window.Measurement = Backbone.Model.extend
    defaults:
      value: '000'
      
    url: ->
      return "/api/measurements/#{@id}" if @id
      "/api/measurements"
  
  window.AppView = Backbone.View.extend
    el: $("#page"),
    render: ->
      $(this.el).html("Welcome")
  
  window.MeasurementView = Backbone.View.extend
    el: $("#page"),
    
    template: ->
      Mustache.to_html(Templates[@templatePath()], @model.toJSON())
    
    initialize: ->
      @model.bind('change', @render, @)

  window.NewMeasurementView = MeasurementView.extend
    
    events: {
      'submit #submission' : 'manifest',
      'submit #manifest'   : 'create'
    }
    
    templatePath: ->
      return 'measurements/complete' if @model.get('id')
      return 'measurements/manifest' if(@model.get('value') != '000')
      'measurements/new'
    
    render: ->
      $(@el).html(@template())
      @.$('#level').select().focus()
      return @
    
    manifest: ->
      @model.set({value: $('#level').val()})
      false
    
    create: ->
      @model.save {value: $('#level').val()},
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