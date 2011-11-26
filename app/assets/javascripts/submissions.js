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
});