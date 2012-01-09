App.Routers.Maps = Backbone.Router.extend
  routes:
    "my/maps/new"      : "new",
    "my/maps/:id"      : "show",
    "my/maps/:id/edit" : "edit",
    "my/maps"          : "index"
    
  initialize: ->
    if !App.hasOwnProperty('currentMap')
      App.currentMap = new App.Models.Map()
    @newMapView = new App.Views.Maps.New
      model: App.currentMap
    @indexMapsView = new App.Views.Maps.Index()
    @showMapView = new App.Views.Maps.Show
      model: App.currentMap
    @editMapView = new App.Views.Maps.Edit
      model: App.currentMap
  
  new: ->
    map = new App.Models.Map()
    App.currentMap = map
    @newMapView.model = map
    @newMapView.initialize().render()
    #if window.hasOwnProperty('google')
    #  window.map = new window.google.maps.Map(document.getElementById("map_canvas"), myOptions)
    #don't really like this logic here, but it's the only way to guarantee that the DOM elements are there
    
        
  
  index: ->
    @indexMapsView.render()
  
  show: (id) ->
    @showMapView.model = App.currentMap
    @showMapView.initialize()
    @showMapView.render()
  
  edit: (id) ->
    @editMapView.model = App.currentMap
    @editMapView.initialize()
    @editMapView.render()
    if window.hasOwnProperty('google')
      window.map = new window.google.maps.Map(document.getElementById("map_canvas"), myOptions)