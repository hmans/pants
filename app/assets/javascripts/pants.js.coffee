$(document).bind 'page:load', ->
  # Fix stupid Chrome bug.
  # See https://code.google.com/p/chromium/issues/detail?id=388664
  #
  $('form').each ->
    $(this).attr('action', this.action);

  $('[autofocus="autofocus"]').focus()

$(document).on 'page:change', ->
  _gs('track') if (_gs?)
  ga('send', 'pageview') if (ga?)
