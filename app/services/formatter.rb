class Formatter < Slodown::Formatter
  def kramdown_options
    { coderay_css: 'class', input: 'GFM' }
  end

private

  def sanitize_config
    super.tap do |config|
      config[:attributes]['a'].delete('rel')
    end
  end
end
