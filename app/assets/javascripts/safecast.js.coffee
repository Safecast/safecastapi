jQuery ->
  App.Router = Backbone.Router.extend
    routes:
      "my/measurements/new": 'newMeasurement'
      "my/measurements/manifest": 'manifestMeasurement'
    
    newMeasurement: ->
      measurement = new App.Models.Measurement()
      if !App.Views.newMeasurement
        App.Views.newMeasurement = new App.Views.NewMeasurement
          model: measurement
      $('div#page').html(App.Views.newMeasurement.render().$el.html())
      if window.hasOwnProperty('google')
        window.map = new window.google.maps.Map(document.getElementById("map_canvas"), myOptions)
      false
    
    manifestMeasurement: ->
      