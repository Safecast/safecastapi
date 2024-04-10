window.addEventListener('DOMContentLoaded', function (event) {
  $(document).on('click', 'a[data-behavior=run-api]', function () {
    $('#api-loading').hide();
    $('#api-output').text('');
    $('#api-modal').modal();
    var url = $(this).attr('href');
    $('.api-url').text(url);
    $.get(url).success(function (data) {
      $('#api-loading').hide()
      $('#api-output').text(JSON.stringify(data, null, 4))
      window.prettyPrint && prettyPrint()
    });
    return false;
  });
})
