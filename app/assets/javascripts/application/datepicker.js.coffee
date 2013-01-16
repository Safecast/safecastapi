jQuery ->
  $('.datetimepicker').each (index, item) ->
    $(item).datetimepicker({
      language: 'en-US'
    });