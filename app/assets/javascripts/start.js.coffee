jQuery ->
  App.homeRouter = new App.Routers.Home()
  App.measurementsRouter = new App.Routers.Measurements()
  App.mapsRouter = new App.Routers.Maps()
  Backbone.history.start({pushState: true, root: '/'});