class Post < ActiveRecord::Base
  validates :body,
    presence: true

  before_save do
    self.sha = calculate_sha
    self.short_sha = sha.first(8)
  end

  def calculate_sha
    Digest::SHA1.hexdigest(body)
  end

  def to_param
    short_sha
  end
end
