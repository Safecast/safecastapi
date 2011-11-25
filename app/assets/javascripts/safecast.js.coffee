jQuery ->
  window.Measurement = Backbone.Model.extend({})
  
  window.AppView = Backbone.View.extend({
    el: $("#page"),
    render: ->
      $(this.el).html("Welcome to Safecast");  
  })
  
  
  window.HomeRouter = Backbone.Router.extend
    routes:
      "*actions": "show"

    show: ->
      appView.render()
  
  window.SubmissionsRouter = Backbone.Router.extend
    routes:
      "my/submissions/new": "new"
    
    new: ->
      
      
  
  appView = new AppView()
  new HomeRouter()
  Backbone.history.start({pushState: true, root: '/'})