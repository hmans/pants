class UserPinger
  include Backgroundable

  def initialize(user_url, body = {})
    @user_url = user_url
    @body = body
  end

  def ping!
    Rails.logger.info "Pinging user #{@user_url} with #{@body.to_json}"
    HTTParty.post(URI.join(@user_url.with_http, '/ping'), body: @body)
  end
end
