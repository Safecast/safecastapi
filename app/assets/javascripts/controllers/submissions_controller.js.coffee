window.Submissions = {
  add: ->
    $('#page').html(Templates['submissions/new'])
  create: ->
    Safecast.current_measurement = {
      level: $('#level').val()
    }
    route_to('/my/submissions/manifest')
    return false
  manifest: ->
    $('#page').html(
      Mustache.to_html(
        Templates['submissions/manifest'],
        Safecast.current_measurement
      )
    )
}

jQuery ->
  $(document).delegate('form#submission', 'submit', Submissions.create)