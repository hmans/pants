class Formatter < Slodown::Formatter
  def kramdown_options
    { coderay_css: 'class' }
  end
end
