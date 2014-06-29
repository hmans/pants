class User < ActiveRecord::Base
  has_secure_password validations: false

  dragonfly_accessor :image

  scope :hosted, -> { where(hosted: true) }

  validates :domain, :url,
    presence: true,
    uniqueness: true

  validates :password,
    presence: { on: :create },
    confirmation: { allow_blank: true },
    if: :hosted

  validates :password_digest,
    presence: true,
    if: :hosted

  has_many :posts,
    foreign_key: 'domain',
    primary_key: 'domain'

  has_many :timeline_entries,
    dependent: :destroy

  has_many :friendships,
    dependent: :destroy

  has_many :incoming_friendships,
    class_name: 'Friendship',
    foreign_key: 'friend_id'

  has_many :friends,
    through: :friendships,
    as: :friend

  has_many :incoming_friends,
    through: :friendships,
    as: :user

  before_validation do
    self.url ||= "http://#{domain}/"
  end

  def external_image_url
    URI.join(url, '/user.jpg')
  end

  def add_to_timeline(post)
    from_friend = (post.user == self) || friends.where(domain: post.domain).any?

    timeline_entries
      .where(post_id: post.id)
      .first_or_create!(from_friend: from_friend)
  end

  def add_friend(friend)
    friendships.where(friend_id: friend.id).first_or_create!
  end

  def ping!(body)
    HTTParty.post(URI.join(url, '/ping'), body: body)
  end

  class << self
    def fetch_from(url)
      unless url =~ %r{^https?://}
        url = "http://#{url}"
      end

      uri = URI.parse(url)
      json = HTTParty.get(URI.join(uri, '/user').to_s, query: { format: 'json' })

      # Sanity checks
      if json['domain'] != uri.host
        raise "User JSON didn't match expected host."
      end

      if json['url'] != URI.join(uri, '/').to_s
        raise "User JSON didn't match expected URL."
      end

      # Upsert user
      user = where(domain: json['domain']).first_or_initialize
      user.attributes = json
      user.save!

      user
    end
  end
end
