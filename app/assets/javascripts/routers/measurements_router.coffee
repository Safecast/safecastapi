App.Routers.Measurements = Backbone.Router.extend
  routes:
    "my/measurements/new" : "new",
    "my/measurements/:id" : "show",
    "my/measurements"     : "index"
    
  initialize: ->
    if !App.hasOwnProperty('currentMeasurement')
      App.currentMeasurement = new App.Models.Measurement()
    @newMeasurementView = new App.Views.Measurements.New
      model: App.currentMeasurement
    @indexMeasurementsView = new App.Views.Measurements.Index()
    @showMeasurementView = new App.Views.Measurements.Show
      model: App.currentMeasurement
  
  new: ->
    measurement = new App.Models.Measurement()
    App.currentMeasurement = measurement
    @newMeasurementView.model = measurement
    @newMeasurementView.initialize().render()
    if window.hasOwnProperty('google')
      window.map = new window.google.maps.Map(document.getElementById("map_canvas"), myOptions)
  
  index: ->
    @indexMeasurementsView.render()
  
  show: (id) ->
    @showMeasurementView.model = App.currentMeasurement
    @showMeasurementView.initialize()
    @showMeasurementView.render()