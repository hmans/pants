class Formatter < Slodown::Formatter
  def kramdown_options
    { coderay_css: 'class', input: 'GFM' }
  end

  def autolink_hashtags(user)
    base_url = user.try(:url)
    @current.gsub!(TagExtractor::REGEX) do
      tag_url = URI.join(base_url, "/tag/#{$1.downcase}")
      "<a href=\"#{tag_url}\" class=\"hashtag p-category\">##{$1}</a>"
    end

    self
  end

private

  def sanitize_config
    super.tap do |config|
      config[:attributes]['a'].delete('rel')
    end
  end
end
