App.Views.Maps.Show = App.Views.App.extend
  
  templatePath: ->
    'maps/show'

  initialize: ->
    @model.bind('change', @render, @)
    
  render: ->
    $(@el).html(@template())