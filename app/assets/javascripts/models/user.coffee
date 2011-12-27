App.Models.User = Backbone.Model.extend
  valid: ->
    !@validate(@attributes)
  
  url: ->
    return "/api/users/#{@id}" if @id
    "/api/users"
  
  validate:
    email:
      required: true
    password:
      required: true