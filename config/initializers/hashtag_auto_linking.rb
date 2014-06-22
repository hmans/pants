# monkey-patch user name auto linking into the kramdown
# converter provided by slodown.
#
Kramdown::Converter::SlodownHtml.class_eval do
  def convert_text(el, opts)
    if @stack.last && @stack.last.type == :a
      super
    else
      super.gsub(TagExtractor::REGEX) do
        "<a href=\"/tag/#{$1}\">##{$1}</a>"
      end
    end
  end
end

