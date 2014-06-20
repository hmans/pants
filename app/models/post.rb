class Post < ActiveRecord::Base
  before_validation do
    self.sha = calculate_sha
    self.short_sha = sha.first(8)
  end

  validates :body,
    presence: true

  validates :sha, :short_sha,
    presence: true,
    uniqueness: true

  belongs_to :successor,
    class_name: 'Post',
    foreign_key: 'successor_sha',
    primary_key: 'sha'

  has_one :predecessor,
    class_name: 'Post',
    foreign_key: 'successor_sha',
    primary_key: 'sha'

  scope :fresh, -> { where(successor_sha: nil) }

  def calculate_sha
    Digest::SHA1.hexdigest(body)
  end

  def to_param
    short_sha
  end
end
