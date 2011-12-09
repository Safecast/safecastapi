jQuery ->
  App.homeRouter = new App.Routers.Home()
  App.measurementsRouter = new App.Routers.Measurements()
  Backbone.history.start({pushState: true, root: '/'});