jQuery ->
  if $('#progress').length > 0
    if $('#progress').data('status') != 'done'
      setInterval(->
        if $('#progress').data('status') != 'done'
          if $('#map_canvas').length > 0
            $('#bgeigie-status').load(document.location.href)
          else
            # document.location.reload(true)
      , 5000)