jQuery ->
  
  handleClick = ->
    homeRouter.navigate($(@).attr('href').replace(/^(\/)/,''), true)
    return false

  $(document).on 'click', 'a[data-pjax]', handleClick