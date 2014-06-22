module TagExtractor
  REGEX = /\B#(\w*[a-zA-Z]+\w*)/

  def self.extract_tags(string)
    string.scan(REGEX).flatten.uniq
  end
end
