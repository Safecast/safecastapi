window.addEventListener('DOMContentLoaded', function () {
  $('.datetimepicker').each(function (index, item) {
    $(item).datetimepicker({format: 'YYYY/MM/DD HH:mm:ss'});
  });
});
