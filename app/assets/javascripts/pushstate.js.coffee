jQuery ->
  
  handleClick = ->
    $('title').text($(@).attr('title'))
    App.router.navigate($(@).attr('href').replace(/^(\/)/,''), true)
    return false

  $(document).on 'click', 'a[data-pjax]', handleClick