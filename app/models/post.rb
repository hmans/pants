class Post < ActiveRecord::Base
  validates :body,
    presence: true

  before_save do
    self.sha = calculate_sha
  end

  def calculate_sha
    Digest::SHA1.hexdigest(body)
  end
end
