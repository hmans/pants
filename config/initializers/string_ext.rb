class String
  def with_http
    with_http? ? self : "http://#{self}"
  end

  def without_http
    sub %r{^https?://}, ''
  end

  def with_http?
    !(%r{^https?://} =~ self).nil?
  end

  def to_guid
    without_http.sub(%r{/+$}, '')
  end
end
