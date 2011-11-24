window.Submissions = {
  add: ->
    $('#page').html(Templates['submissions/new.html.mustache'])
  create: ->
    Submissions.manifest()
    return false
  manifest: ->
    $('#page').html(Templates['submissions/manifest.html.mustache'])
}

jQuery ->
  $(document).delegate('form#submission', 'submit', Submissions.create)