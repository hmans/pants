$(document).bind 'page:load', ->
  $('[autofocus="autofocus"]').focus()

$(document).on 'page:change', ->
  _gs('track') if (_gs?)
