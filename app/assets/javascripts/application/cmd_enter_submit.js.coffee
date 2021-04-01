jQuery ->
  $(document).on 'keydown', 'textarea', (event) ->
    if (event.metaKey || event.shiftKey) && event.which == 13
      $(@).parents('form:first').submit()