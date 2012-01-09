jQuery ->
  App.homeRouter = new App.Routers.Home()
  App.measurementsRouter = new App.Routers.Measurements()
  App.mapsRouter = new App.Routers.Maps()
  App.usersRouter = new App.Routers.Users()
  Backbone.history.start({pushState: true, root: '/'});