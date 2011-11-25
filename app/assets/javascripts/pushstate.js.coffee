jQuery ->
  
  handleClick = ->
    submissionsRouter.navigate($(@).attr('href').replace(/^(\/)/,''), true)
    return false

  $(document).on 'click', 'a[data-pjax]', handleClick