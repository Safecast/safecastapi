jQuery ->
  window.Measurement = Backbone.Model.extend({})
  
  window.AppView = Backbone.View.extend
    el: $("#page"),
    render: ->
      $(this.el).html("Welcome to Safecast")

  window.SubmissionsView = Backbone.View.extend
    el: $("#page"),
    render: ->
      $(this.el).html(Templates['submissions/new'])
  
  
  window.HomeRouter = Backbone.Router.extend
    routes:
      "*actions": "show"

    show: ->
      appView.render()
  
  window.SubmissionsRouter = Backbone.Router.extend
    routes:
      "my/submissions/new": "new"
    
    new: ->
      submissionsView.render()
      
  
  appView = new AppView()
  submissionsView = new SubmissionsView()
  window.homeRouter = new HomeRouter()
  window.submissionsRouter = new SubmissionsRouter()
  Backbone.history.start({pushState: true, root: '/'})