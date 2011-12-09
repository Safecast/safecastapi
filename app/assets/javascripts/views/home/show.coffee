App.Views.Home.Show = App.Views.App.extend
  el: $("#page"),

  render: ->
    $(this.el).html("Welcome")