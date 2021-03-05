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
//= require bootstrap-sprockets
//= require bootstrap-datetimepicker.min
//= require bootstrap-rowlink.min
//= require moment
//= require bootstrap-datetimepicker
//= require_tree ./application
//- require_self

jQuery.ajaxSetup({
  beforeSend: function(xhr) {
    xhr.setRequestHeader("Accept", "text/javascript");
  }
});

var searchForm = document.querySelector("#search_form form");
if (searchForm) {
  searchForm.addEventListener("ajax:beforeSend", function () {
    var state = $(searchForm).serializeArray();
    history.pushState({}, document.title, "?" + $.param(state));
  });

  var searchBox = searchForm.querySelector("input[type=search]");
  if (searchBox) {
    searchBox.addEventListener("input", _.debounce(function () {
      searchForm.submit();
    }, 200));
  }
}