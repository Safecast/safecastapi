App.Views.Measurements.Show = App.Views.App.extend
  
  templatePath: ->
    'measurements/show'

  initialize: ->
    @model.bind('change', @render, @)
    
  render: ->
    $(@el).html(@template())