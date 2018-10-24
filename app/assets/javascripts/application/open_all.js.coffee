jQuery ->

$("#open_all").click ->

  imports = $(this).data('bgeigie');
  for dataset in imports
    window.open("bgeigie_imports/"+dataset.id) unless dataset.approved