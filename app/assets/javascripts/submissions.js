$(document).ready(function(){

  /* focus */
  $('.field input').focus(function(){
    $(this).parents('.field:first').addClass('focus');
  });

  $('.field input').blur(function(){
    $(this).parents('.field:first').removeClass('focus');
  });

  /* unit selector */
  $('.units li').click(function(){
    $('.units li').addClass('unselected');
    $('.units li').removeClass('selected');
    $(this).addClass('selected');
    $(this).removeClass('unselected');
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