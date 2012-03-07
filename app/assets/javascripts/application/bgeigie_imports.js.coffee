jQuery ->
  if $('#progress').length > 0
    if $('#progress').data('status') != 'done'
      setInterval(->
        if $('#progress').data('status') != 'done'
          $('#bgeigie-status').load(document.location.href)
      , 5000)