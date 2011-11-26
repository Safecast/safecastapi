jQuery ->
  window.Measurement = Backbone.Model.extend({})
  
  window.AppView = Backbone.View.extend
    el: $("#page"),
    render: ->
      $(this.el).html("Welcome to Safecast")

  window.SubmissionsView = Backbone.View.extend
    el: $("#page"),
    
    events: {
      'submit #submission' : 'manifest'
    }
    
    template: (file)->
      Mustache.to_html(Templates[file], @model.toJSON())
    
    render: ->
      console.log(@model.get('level'))
      if(@model.get('level') != '000')
        $(this.el).html(@template('submissions/manifest'))
      else
        $(this.el).html(@template('submissions/new'))
      return @
    
    manifest: ->
      console.log(@.$('#input').val())
      @model.set({level: $('#level').val()})
      @render()
      return false
  
  
  window.HomeRouter = Backbone.Router.extend
    routes:
      "*actions": "show"

    show: ->
      appView.render()
  
  window.SubmissionsRouter = Backbone.Router.extend
    routes:
      "my/submissions/new": "new"
    
    new: ->
      measurement = new Measurement({level: '000'})
      new SubmissionsView({model: measurement}).render()
      
  
  appView = new AppView()
  window.homeRouter = new HomeRouter()
  window.submissionsRouter = new SubmissionsRouter()
  Backbone.history.start({pushState: true, root: '/'})