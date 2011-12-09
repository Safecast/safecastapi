App.Views.App = Backbone.View.extend
  el: $("#page"),
  
  template: (path) ->
    path = @templatePath() unless path
    Mustache.to_html(Templates[path], @model.toJSON())