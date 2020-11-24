// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require json2
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require underscore
//= require bootstrap
//= require bootstrap-datetimepicker.min
//= require bootstrap-rowlink.min
//= require_tree ./application
//- require_self

jQuery.ajaxSetup({
  'beforeSend': function(xhr) {
    xhr.setRequestHeader("Accept", "text/javascript");
  }
});

$("#search_form form").keyup(_.debounce(function (e) {
    if(e.key.length == 1 || e.key == 'Backspace')
    {
        var input = $(this).find('input[type=search]');
        var query = '?' + input.serialize();
        input.submit();
        history.pushState({}, '', query);
    }
}, 200));
