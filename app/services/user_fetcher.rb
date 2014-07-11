class UserFetcher
  include Backgroundable

  # The following attributes will be copied from user JSON responses
  # into local Post instances.
  #
  ACCESSIBLE_JSON_ATTRIBUTES = %w{
    display_name
    domain
    locale
    url
  }

  def initialize(url, opts = {})
    @url = expand_url(url)
    @uri = URI.parse(@url)
    @opts = opts
  end

  def fetch!
    Rails.logger.info "Fetching user: #{@url}"

    User.transaction do
      @user = User.where(domain: @uri.host).first_or_initialize

      if should_fetch?
        @json = fetch_json

        if json_sane?
          # Transfer attributes from JSON.
          @user.attributes = @json.slice(*ACCESSIBLE_JSON_ATTRIBUTES)

          # NOTE: We always set #updated_at because the previous operation may
          # not have changed any attributes. In this case, the following #save!
          # would essentially no-op.
          @user.updated_at = Time.now

          # Done!
          @user.save!
        end
      else
        Rails.logger.info "-> Skipping #{@url}, recently fetched."
      end

      # Return user.
      @user
    end
  end

  def should_fetch?
    @opts[:force] || @user.new_record? || @user.updated_at < 30.minutes.ago
  end

  def expand_url(url)
    URI.join(url.with_http, '/user.json').to_s
  end

  def fetch_json
    HTTParty.get(@url)
  end

  def json_sane?
    raise "User JSON invalid: domain doesn't match" if @json['domain'] != @uri.host
    raise "User JSON invalid: URL doesn't match" if @json['url'].without_http != URI.join(@uri, '/').to_s.without_http

    true
  end
end
