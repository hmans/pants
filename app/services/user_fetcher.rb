class UserFetcher < Service
  attr_reader :url, :uri, :opts, :response, :data

  class InvalidData < RuntimeError ; end

  # The following attributes will be copied from user JSON responses
  # into local Post instances.
  #
  ACCESSIBLE_JSON_ATTRIBUTES = %w{
    display_name
    domain
    locale
    url
  }

  def perform(url, opts = {})
    @url = url.with_http
    @uri = URI.parse(@url)
    @opts = opts

    logger.info "Fetching user: #{@url}"

    User.transaction do
      @user = User.where(domain: @uri.host).first_or_initialize

      if should_fetch?
        @response = HTTParty.get(url)

        # @data = extract_mf2 || fetch_pants_json
        @data = fetch_pants_json
        return nil if @data.blank?

        if data_sane?
          # Transfer attributes from JSON.
          @user.attributes = @data.slice(*ACCESSIBLE_JSON_ATTRIBUTES)

          # NOTE: We always set #updated_at because the previous operation may
          # not have changed any attributes. In this case, the following #save!
          # would essentially no-op.
          @user.updated_at = Time.now

          # Done!
          @user.save!
        end
      else
        logger.info "-> Skipping #{@url}, recently fetched."
      end

      # Return user.
      @user
    end
  end

  private

  def should_fetch?
    @opts[:force] || @user.new_record? || @user.updated_at < 30.minutes.ago
  end

  def extract_mf2
    if mf2 = Microformats2.parse(@response.body)
      if (card = mf2.try(:card)).present?
        {
          "display_name" => card.name.to_s,
          "domain" => uri.host,
          "url" => url
        }
      end
    end
  end

  def fetch_pants_json
    response = HTTParty.get(URI.join(uri, '/user.json'))
    response.to_hash if response.success?
  end

  def data_sane?
    if @data['domain'] != @uri.host
      raise InvalidData, "Domain #{@data['domain']} doesn't match expected domain #{@uri.host} (#{@url})"
    end

    expected_url = URI.join(@uri, '/').to_s
    if @data['url'].to_guid != expected_url.to_guid
      raise InvalidData, "URL #{@data['url']} doesn't match expected URL #{expected_url} (#{@url})"
    end

    true
  end
end
