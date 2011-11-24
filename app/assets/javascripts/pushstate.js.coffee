jQuery ->

  route = ->
    if(window.Routes[document.location.pathname])
      window.Routes[document.location.pathname]['action']()
  
  handleClick = ->
    History.pushState({}, Routes[$(@).attr('href')]['title'], $(@).attr('href'))
    route()
    return false
  $(document).delegate 'a', 'click', handleClick
  
  route()