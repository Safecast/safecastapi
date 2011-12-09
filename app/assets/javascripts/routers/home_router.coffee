App.Routers.Home = Backbone.Router.extend
  routes:
    ""            : "show"

  initialize: ->
    @showHomeView = new App.Views.Home.Show()

  show: ->
    @showHomeView.render()