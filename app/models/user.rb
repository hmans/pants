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

  has_many :followings,
    class_name: 'Friendship',
    foreign_key: 'friend_id'

  has_many :friends,
    through: :friendships,
    source: :friend

  has_many :followers,
    through: :followings,
    source: :user

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
    # Upsert friendship
    friendships.where(friend_id: friend.id).first_or_create!

    # Make existing timeline posts visible
    timeline_entries.joins(:post).where(posts: { domain: friend.domain }).update_all(from_friend: true)
  end

  def ping!(body)
    UserPinger.new.async.perform(url, body)
  end

  class << self
    # The following attributes will be copied from user JSON responses
    # into local Post instances.
    #
    ACCESSIBLE_JSON_ATTRIBUTES = %w{
      display_name
      domain
      locale
      url
    }

    def fetch_from(url)
      uri = URI.parse(url.with_http)
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
      user.attributes = json.slice(*ACCESSIBLE_JSON_ATTRIBUTES)
      user.save!

      user
    end
  end
end
