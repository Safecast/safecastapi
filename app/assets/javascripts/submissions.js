$(document).ready(function(){

  /* focus */
  $('.field input').focus(function(){
    $(this).parents('.field:first').addClass('focus');
  });

  $('.field input').blur(function(){
    $(this).parents('.field:first').removeClass('focus');
  });
  
  /* mock-up sign in / sign up thing */
  $('input#email').blur(function(){
    $('p.note').text("...");
    $('input[type="submit"]').attr('value','...');
    setTimeout(function(){
      $('p.note').text("Welcome back, Sean.");
      $('input[type="submit"]').attr('value','Sign in');
    }, 750);
  });

  /* unit selector */
  $('.units li').click(function(){
    $(this).siblings('li').removeClass('selected');
    $(this).addClass('selected');
    return false;
  });

  /* digit field */
  $('input.digit').keydown(function(event){
    if ( event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 190 || event.keyCode == 9 ) {} else {
      if ((event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
          event.preventDefault(); 
      }   
    }
  });
});