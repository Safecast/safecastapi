jQuery ->
  $('.datetimepicker').each (index, item) ->
    $(item).datetimepicker({
      format: 'YYYY/MM/DD HH:mm:ss'
    });