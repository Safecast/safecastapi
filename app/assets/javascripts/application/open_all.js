window.addEventListener('DOMContentLoaded', function () {
  $("#open_all").click(function () {
    var import_url_list = $(this).data('bgeigie');
    if (import_url_list.length != 0) {
      for (bgeigie_import_url in import_url_list) {
        window.open(bgeigie_import_url)
      }
    } else {
      alert("There are no unmoderated files on this side!");
    }
  });
});
