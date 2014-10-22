class Webmentioner < Service
  def perform(source, target, opts = {})
    # If we can find a webmention endpoint, send a webmention; otherwise,
    # fallback to legacy /ping implementation.
    #
    if endpoint = client.supports_webmention?(target)
      logger.info "Using webmention endpoint: #{endpoint}"
      client.send_mention(endpoint, source, target)
    else
      ping_url = URI.join(target, '/ping')
      logger.info "Using legacy ping: #{ping_url}"
      HTTP.post(ping_url, body: { url: source })
    end
  end

private

  def client
    Webmention::Client
  end
end
