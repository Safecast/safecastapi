jQuery ->
  window.Measurement = Backbone.Model.extend
    defaults:
      value: '000'
    
    url: '/api/measurements'
  
  window.AppView = Backbone.View.extend
    el: $("#page"),
    render: ->
      $(this.el).html("Welcome to Safecast")

  window.SubmissionsView = Backbone.View.extend
    el: $("#page"),
    
    events: {
      'submit #submission' : 'manifest',
      'submit #manifest'   : 'create'
    }
    
    initialize: ->
      @model.bind('change', @render, @)
    
    templatePath: ->
      return 'submissions/complete' if @model.get('id')
      return 'submissions/manifest' if(@model.get('value') != '000')
      'submissions/new'
    
    template: ->
      Mustache.to_html(Templates[@templatePath()], @model.toJSON())
    
    render: ->
      $(this.el).html(@template())
      @.$('#level').select().focus()
      return @
    
    manifest: ->
      @model.set({value: $('#level').val()})
      false
    
    create: ->
      @model.save {value: $('#level')}
      false
  
  
  window.HomeRouter = Backbone.Router.extend
    routes:
      "*actions": "show"

    show: ->
      appView.render()
  
  window.SubmissionsRouter = Backbone.Router.extend
    routes:
      "my/submissions/new": "new"
    
    new: ->
      measurement = new Measurement()
      new SubmissionsView({model: measurement}).render()
      
  
  appView = new AppView()
  window.homeRouter = new HomeRouter()
  window.submissionsRouter = new SubmissionsRouter()
  Backbone.history.start({pushState: true, root: '/'})