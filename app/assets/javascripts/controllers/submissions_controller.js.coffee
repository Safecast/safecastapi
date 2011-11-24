window.Submissions = {
  add: ->
    $('#page').html(Templates['submissions/new'])
  create: ->
    route_to('/my/submissions/manifest')
    return false
  manifest: ->
    $('#page').html(Templates['submissions/manifest'])
}

jQuery ->
  $(document).delegate('form#submission', 'submit', Submissions.create)