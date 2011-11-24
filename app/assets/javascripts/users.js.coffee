jQuery ->
  $('#signup-register-form input').blur ->
    $.get('/api/users/finger.json', {email: $.trim($('#email-field').val())}, (response) ->
      if(response is null and $.trim($('#email-field').val()))
        $('#name-field').show()
        $('#sign-in-register').val('Register')
      else
        $('p#note').text("Welcome back, #{response.first_name}.")
        $('#name-field').hide()
        
    )