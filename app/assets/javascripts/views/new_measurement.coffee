App.Views.NewMeasurement = App.Views.App.extend
  
  initialize: ->
    @model.bind('change', @render, @)
    @model.bind('error', @alertError, @)
    
    
    return @
  
  setUnit: (e) ->
    $('#unit').val($(e.target).data('value'))

  events:
    'submit #submission' : 'manifest'
    
    'keydown #location'  : 'geocodeSearch'
    'click .gps'         : 'geocodeSearch'
    'click .unit'        : 'setUnit'
  
  alertError: ->
    $('form#submission').effect('shake', {
      distance: 10
    }, 100)

  showMap: (e)->

  
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