window.Submissions = {
  add: ->
    $('#page').html(Templates['submissions/new'])
  create: ->
    $.post("/api/measurements.json",{
      measurement:
        value: $('#value').val()
    })
    $('#page').html(Templates['submissions/complete'])
    return false
  manifest: ->
    Safecast.current_measurement = {
      level: $('#level').val()
    }
    $('#page').html(
      Mustache.to_html(
        Templates['submissions/manifest'],
        Safecast.current_measurement
      )
    )
    return false
}

jQuery ->
  $(document).on('submit', 'form#submission', Submissions.manifest)
  $(document).on('submit', 'form#manifest', Submissions.create)
  # $(document).on('click', '#level', ->
  #   $(@).select()
  # )