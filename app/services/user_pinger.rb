class UserPinger
  include BackgroundJob

  def perform(user_url, body = {})
    with_appsignal do
      Rails.logger.info "Pinging user #{user_url} with #{body.to_json}"
      HTTParty.post(URI.join(user_url.with_http, '/ping'), body: body)
    end
  end
end
