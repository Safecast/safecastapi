window.addEventListener("DOMContentLoaded", function () {
  $(document).on('keydown', 'textarea', function (event) {
    if ((event.metaKey || event.shiftKey) && event.which == 13) {
      $(this).parents('form:first').submit();
    }
  });
});
