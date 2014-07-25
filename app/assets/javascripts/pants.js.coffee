initPage = ->
  # Fix stupid Chrome bug.
  # See https://code.google.com/p/chromium/issues/detail?id=388664
  #
  $('form').each ->
    $(this).attr('action', this.action);

  # Autofocus form fields with autofocus. We need to do this even though
  # browsers do it natively because (due to Turbolinks), we're always just
  # on the same single page. Duh!
  #
  $('[autofocus="autofocus"]').focus()

  # When images fail loading, replace them with our magic transparent pixel.
  #
  $("img").error ->
    $(this).attr("src", "/images/1x1.png")

  # Run dem trackers if available.
  #
  _gs('track') if (_gs?)
  ga('send', 'pageview') if (ga?)


$(document).on 'page:change', initPage

$ ->
  initPage()
