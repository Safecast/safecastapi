jQuery ->
  $('#signup-register-form input').blur ->
    $.get '/api/users/finger.json', {email: $.trim($('#email-field').val())}, (response) ->
      if(response is null and $.trim($('#email-field').val()))
        $('#name-field').show()
        $('#sign-in-register').val('Register')
        $('#user_name').focus() if $('#user_name').is(':blank')
        $('#note').hide()
      else
        $('#name-field').hide()
        $('#sign-in-register').val('Sign in')
        $('#note').show().text(
          if response.first_name?
            "Welcome back, #{response.first_name}."
          else
            "Welcome back.")
