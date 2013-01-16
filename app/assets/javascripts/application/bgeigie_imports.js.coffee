jQuery ->
  if $('div#current-status').length
    current_status_interval = setInterval ->
      $.get(BgeigieImport.current_status_url, {}, 'html').success (data)->
        if $.trim(data) == ''
          clearInterval(current_status_interval)
        else
          $('#current-status').html(data)
    , 5000