class User < ActiveRecord::Base
  has_secure_password validations: false

  # Scopes
  #
  scope :hosted, -> { where(hosted: true) }
  scope :remote, -> { where(hosted: false) }

  # Validations
  #
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

  # Associations
  #
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
    self.display_name ||= domain
    self.url ||= domain.try(:with_http)
  end

  concerning :Images do
    included do
      dragonfly_accessor :image
      dragonfly_accessor :flair
    end

    def external_image_url
      URI.join(url, '/user.jpg').to_s
    end

    def external_flair_url
      URI.join(url, '/user-flair.jpg').to_s
    end

    def local_image
      hosted? ? image : Dragonfly.app.fetch_url(external_image_url)
    end

    def local_flair
      hosted? ? flair : Dragonfly.app.fetch_url(external_flair_url)
    end

    def local_thumbnail
      local_image.try(:thumb, '300x300#')
    end

    def local_cropped_flair
      local_flair.try(:thumb, '800x250#')
    end
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

  # Returns a list of locally known users that have posts waiting
  # in this user's incoming timeline.
  #
  def incoming_followers
    User.where(domain: timeline_entries.from_others.includes(:post).pluck('distinct domain'))
  end

  def ping!(body)
    UserPinger.perform_async(url, body)
  end

  concerning :Polling do
    included do
      scope :can_be_polled, -> { remote.where("last_polled_at IS NULL OR last_polled_at < ?", 15.minutes.ago) }
    end

    # Poll this user's posts via HTTP and place their posts in the
    # timelines of followers (aka incoming friends.)
    #
    def poll!
      # Never poll for hosted users.
      unless hosted?
        posts_url = URI.join(url, '/posts.json')
        posts_json = HTTParty.get(posts_url, query: { updated_since: last_polled_at.try(:to_i) })

        # upsert posts in the database
        posts = posts_json.reverse.map do |json|
          # Sanity checks
          if json['domain'] != domain
            raise "#{posts_url} contained an invalid domain."
          end

          # upsert post in local database
          Post.from_json!(json)
        end

        # add posts to local followers' timelines
        followings.includes(:user).each do |friendship|
          posts.each do |post|
            if friendship.created_at <= post.edited_at
              friendship.user.add_to_timeline(post)
            end
          end
        end

        posts
      end
    ensure
      touch(:last_polled_at)
    end
  end

  class << self
    def [](url)
      host = URI.parse(url).host
      find_by(domain: host)
    end
  end
end
