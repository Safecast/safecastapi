App.Models.Map = Backbone.Model.extend
  defaults:
    name: 'My new map'
  
  valid: ->
    !@validate(@attributes)
  
  url: ->
    return "/api/maps/#{@id}" if @id
    "/api/maps"
  
  validate:
    name:
      required: true
    description:
      required: true