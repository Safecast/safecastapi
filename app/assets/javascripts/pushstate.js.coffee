jQuery ->

  window.route_to = (route) ->
    if(window.Routes[route])
      History.pushState({}, Routes[route]['title'], route)
      window.Routes[route]['action']()
  
  History.Adapter.bind window,'statechange', ->
    State = History.getState()
    route_to(document.location.pathname)
  
  handleClick = ->
    route_to($(@).attr('href'))
    return false

  $(document).delegate 'a', 'click', handleClick
  
  route_to(document.location.pathname)