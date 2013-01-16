jQuery ->

  showModal = ->
    $('#api-modal').modal()

  $(document).on 'click', 'a[data-behavior=run-api]', ->
    $('#api-loading').hide()
    $('#api-output').text('')
    showModal()
    url = $(@).attr('href')
    $('.api-url').text(url)
    $.get(url).success (data)->
      $('#api-loading').hide()
      $('#api-output').text(JSON.stringify(data, null, 4))
      window.prettyPrint && prettyPrint()
    return false

  $('#docs-nav').affix ->
    offset: $('#docs-nav').position()