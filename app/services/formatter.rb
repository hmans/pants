class Formatter < Slodown::Formatter
  def kramdown_options
    { coderay_css: 'class', input: 'GFM' }
  end

  def autolink_hashtags_and_mentions(user)
    @base_url = user.try(:url)
    document = Nokogiri::HTML.fragment(@current, 'utf-8')

    dat_autolinking(document)

    # Done
    @current = document.to_s
    self
  end

private

  def dat_autolinking(element)
    if element.text?
      text = element.to_s

      # mentions
      text.gsub!(/\B@([\w\-_]+\.[\w.\-_]+)\b/) do
        user_url = URI.join($1.with_http, '/').to_s
        "<a href=\"#{user_url}\" class=\"mention\">@#{$1}</a>"
      end

      # hashtags
      text.gsub!(TagExtractor::REGEX) do
        tag_url = URI.join(@base_url, "/tag/#{$1.downcase}")
        "<a href=\"#{tag_url}\" class=\"hashtag p-category\">##{$1}</a>"
      end

      # Nokogiri hates me
      element.replace Nokogiri::HTML.fragment(text, 'utf-8')
    else
      # WE MUST GO DEEPER
      element.children.each do |child|
        unless %w(pre a).include?(child.name)
          dat_autolinking(child)
        end
      end
    end
  end

  def sanitize_config
    super.tap do |config|
      config[:attributes]['a'].delete('rel')
    end
  end
end
