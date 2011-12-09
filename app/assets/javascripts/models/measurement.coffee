App.Models.Measurement = Backbone.Model.extend
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