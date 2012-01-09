App.Routers.Users = Backbone.Router.extend
  routes:
    "my/account" : "edit"
    
  initialize: ->
    if !App.hasOwnProperty('currentAccount')
      App.currentUser = new App.Models.User()
    @editUserView = new App.Views.Users.Edit
      model: App.currentUser
  
  edit: (id) ->
    @editUserView.model = App.currentUser
    @editUserView.initialize()
    @editUserView.render()