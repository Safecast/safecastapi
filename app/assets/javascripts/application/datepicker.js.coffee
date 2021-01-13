jQuery ->
  $('.datetimepicker').each (index, item) ->
    $(item).datetimepicker({
      format: 'YYYY/MM/DD hh:mm:ss'
    });