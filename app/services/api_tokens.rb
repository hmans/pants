module ApiTokens
  extend self

  def generate(user, site)
    verifier.generate(user: user.id, site: site.id, expires: 30.days.from_now)
  end

private

  def verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(Rails.application.secrets.api_token_secret)
  end
end
