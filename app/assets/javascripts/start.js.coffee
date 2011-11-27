jQuery ->
  window.appView = new AppView()
  window.homeRouter = new HomeRouter()
  window.measurementsRouter = new MeasurementsRouter()
  Backbone.history.start({pushState: true, root: '/'});