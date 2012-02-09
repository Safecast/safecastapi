jQuery ->
  App.router = new App.Router()
  Backbone.history.start({pushState: true, root: '/'});