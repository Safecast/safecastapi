jQuery ->

  window.route_to = (route) ->
    if(window.Routes[route])
      window.Routes[route]['action']()
  
  handleClick = ->
    History.pushState({}, Routes[$(@).attr('href')]['title'], $(@).attr('href'))
    route()
    return false
  $(document).delegate 'a', 'click', handleClick
  
  route_to(document.location.pathname)