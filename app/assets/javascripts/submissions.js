$(document).ready(function(){

  /* focus */
  $(document).delegate('.field input', 'focus', function(){
    $(this).parents('.field:first').addClass('focus');
  });

  $(document).delegate('.field input', 'blur', function(){
    $(this).parents('.field:first').removeClass('focus');
  });

  /* unit selector */
  $(document).delegate('.units li', 'click', function(){
    $(this).siblings('li').removeClass('selected');
    $(this).addClass('selected');
    return false;
  });

  /* digit field */
  $(document).delegate('input.digit', 'keydown', function(event){
    if ( event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 190 || event.keyCode == 9 ) {} else {
      if ((event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
          event.preventDefault(); 
      }   
    }
  });
});