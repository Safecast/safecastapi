jQuery ->
  $('#signup-register-form input').blur ->
    $.get('/api/users/finger.json', {email: $('#email-field').val()}, (response) ->
      if(response is null)
        $('#name-field').show()
        $('#sign-in-register').val('Register')
      else
        $('#name-field').hide()
    )