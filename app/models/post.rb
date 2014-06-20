class Post < ActiveRecord::Base
  before_validation do
    # Render body to HTML
    self.body_html = Formatter.new(body).complete.to_s

    # Update SHAs
    self.created_at ||= Time.now     # for the SHA
    self.sha = calculate_sha
    self.short_sha = sha.first(8)
  end

  validates :body,
    presence: true

  validates :sha, :short_sha,
    presence: true,
    uniqueness: true

  belongs_to :user,
    foreign_key: 'domain',
    primary_key: 'domain'

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
    Digest::SHA1.hexdigest("pants:#{domain}:#{created_at.iso8601}:#{body}")
  end

  def to_param
    short_sha
  end
end
