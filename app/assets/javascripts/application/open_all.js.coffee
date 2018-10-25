
jQuery ->

$("#open_all").click ->

  bgeigie_imports = $(this).data('bgeigie');
  for id in bgeigie_imports
   window.open("bgeigie_imports/"+id)
