
jQuery ->

$("#open_all").click ->

  import_url_list = $(this).data('bgeigie');
  for bgeigie_import_url in import_url_list
    window.open(bgeigie_import_url)
