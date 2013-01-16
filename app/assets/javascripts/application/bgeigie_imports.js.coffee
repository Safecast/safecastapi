jQuery ->
  if !$('div#done').hasClass('bar-success')
    head_interval = setInterval ->
      $.get(BgeigieImport.url, {partial: 'head'}, 'html').success (data)->
        if $('div#done').hasClass('bar-success')
          clearInterval(head_interval)
        else
          $('#head').html(data)
    , 5000