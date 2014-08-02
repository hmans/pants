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

  before_validation do
    self.display_name ||= domain
    self.url ||= domain.try(:with_http)
  end

  # Users can have posts. Which is kind of convenient considering we're dealing
  # with a distributed social _blogging_ platform.
  #
  concerning :Posts do
    included do
      has_many :posts,
        foreign_key: 'domain',
        primary_key: 'domain'
    end
  end

  # Users also have timelines, which are mostly just listings of posts that
  # are filled when the user is being pinged, or someone the user is subscribing
  # to publishes a new post.
  #
  concerning :Timelines do
    included do
      has_many :timeline_entries,
        dependent: :destroy

      # `timeline_posts` returns all posts contained in the user's
      # timeline, no matter its status (from friend/other, hidden/visible etc.)
      # This can be used to quickly check if the user has "seen" a specific post,
      # eg. to determine if another post is in reply to something the user has seen.
      #
      has_many :timeline_posts,
        through: :timeline_entries,
        source: :post
    end

    def add_to_timeline(post)
      from_friend = (post.user == self) || friends.where(domain: post.domain).any?

      TimelineEntry.transaction do
        timeline_entries
          .where(post_id: post.id)
          .first_or_create!(from_friend: from_friend)
      end
    end
  end

  # Awww, friendship. Isn't it lovely? #pants defines a "friendship" as one user
  # subscribing to another user's updates, which is different from what you may
  # know from real life, but works exceedingly well in a computer context.
  #
  # In non-mutual friendships, if user A has user B in their friends list, A is
  # a "follower" of B.
  #
  concerning :Friendships do
    included do
      has_many :friendships,
        dependent: :destroy

      # Please note that the following association only lists followings that are
      # local to your #pants instance.
      #
      has_many :followings,
        class_name: 'Friendship',
        foreign_key: 'friend_id'

      has_many :friends,
        through: :friendships,
        source: :friend

      has_many :followers,
        through: :followings,
        source: :user
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
  end

  # Send ONE ping.
  #
  concerning :Pings do
    included do
      has_many :pings,
        dependent: :nullify
    end
  end

  concerning :WebLinks do
    def web_links_text
      web_links.join("\n")
    end

    def web_links_text=(text)
      self.web_links = text.split.compact.map(&:with_http)
    end
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

  # If A is following B, B is remote (= on a different #pants server), and B doesn't have
  # A in their friends list, B won't push updates to A, so we need to actively poll B for
  # updates.
  #
  concerning :Polling do
    included do
      scope :can_be_polled, -> { remote.where("last_polled_at IS NULL OR last_polled_at < ?", 15.minutes.ago) }
    end

    # Poll this user's posts via HTTP and place their posts in the
    # timelines of followers (aka incoming friends.)
    #
    def poll!
      # Never poll for hosted users.
      unless hosted? || followings.empty?
        posts_url = URI.join(url, '/posts.json').to_s
        posts_json = HTTParty.get(posts_url, query: { updated_since: last_polled_at.try(:to_i) })

        # upsert posts in the database
        posts = posts_json.reverse.map do |json|
          begin
            PostUpserter.perform(json, posts_url)
          rescue StandardError => e
            ExceptionNotifier.notify_exception(e)
            Rails.logger.warn "While polling #{domain}, a post raised: #{e}"
            nil
          end
        end.compact

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
      host = URI.parse(url.with_http).host
      find_by(domain: host)
    end
  end
end
