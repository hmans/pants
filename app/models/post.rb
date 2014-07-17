require 'html/sanitizer'

class Post < ActiveRecord::Base
  # Scopes
  #
  scope :on_date, ->(date) { where(published_at: (date.at_beginning_of_day)..(date.at_end_of_day)) }
  scope :latest, -> { order('published_at DESC') }
  scope :tagged_with, ->(tag) { where("tags @> ARRAY[?]", tag) }
  scope :referencing, ->(guid) { where("? = ANY(posts.references)", guid) }

  # Validations
  #
  before_validation do
    if user.try(:hosted?)
      if body_changed?
        Rails.logger.info "Rendering markdown for #{self}"
        # Resolve hashtag links
        body_with_hashtags = body.gsub(TagExtractor::REGEX) do
          tag_url = URI.join(user.url, "/tag/#{$1.downcase}")
          "<a href=\"#{tag_url}\" class=\"hashtag p-category\">##{$1}</a>"
        end

        # Render body to HTML
        self.body_html = Formatter.new(body_with_hashtags).complete.to_s
      end
    else
      # User is a remote user -- let's sanitize the HTML
      Rails.logger.info "Sanitizing HTML for #{self}"
      self.body_html = Formatter.new(body_html).sanitize.to_s
    end

    # Extract and save tags
    self.tags = TagExtractor.extract_tags(HTML::FullSanitizer.new.sanitize(body_html)).map(&:downcase)

    # Extract and save title
    self.title = to_title.try(:truncate, 200)

    # Generate slug
    self.slug ||= generate_slug

    # Set/update GUID (a validation will check that this never changes)
    self.guid = "#{domain}/#{slug}"

    # Publish post right away
    self.published_at ||= Time.now

    # Default editing timestamp to publishing timestamp
    self.edited_at ||= published_at

    # Default URL to http://<guid>
    self.url ||= "http://#{guid}"
  end

  validate(on: :update) do
    if guid_changed?
      errors.add(:guid, "can not be changed.")
    end

    # TODO: check that URL matches GUID
  end

  validates :body,
    presence: true

  validates :guid, :url,
    presence: true,
    uniqueness: true

  validates :slug,
    presence: true,
    uniqueness: { scope: :domain }

  belongs_to :user,
    foreign_key: 'domain',
    primary_key: 'domain'

  has_many :timeline_entries,
    dependent: :destroy

  def generate_slug
    chars = ('a'..'z').to_a
    numbers = (0..9).to_a

    (Array.new(3) { chars.sample } + Array.new(3) { numbers.sample }).join('')
  end

  def push_to_local_followers
    if user.present?
      user.followers.hosted.find_each do |follower|
        follower.add_to_timeline(post)
      end
    end
  end

  concerning :Representation do
    def to_s
      "[Post #{guid}]"
    end

    def to_param
      slug
    end

    def to_sentences
      to_nokogiri.text.split(/((?<=[a-z0-9)][.?!])|(?<=[a-z0-9][.?!]"))\s+(?="?[A-Za-z])/).reject {|part| part.blank? }
    end

    def to_nokogiri(stripped = true)
      Nokogiri::HTML(body_html).tap do |n|
        if stripped
          n.css('blockquote').remove
        end
      end
    end

    def to_summary(target = 60)
      Rails.cache.fetch("post-summary-#{id}-#{updated_at}", expires_in: 1.day) do
        to_sentences.inject("") do |v, sentence|
          break v if v.length > target
          v << " " << sentence
        end
      end.strip.html_safe
    end

    def title
      read_attribute(:title) || to_title
    end

    def to_title
      (to_nokogiri.css('h1, h2').first.try(:text) || to_sentences.first).try(:strip)
    end
  end

  concerning :References do
    included do
      has_many :replies,
        class_name: 'Post',
        foreign_key: 'referenced_guid',
        primary_key: 'guid'

      belongs_to :reference,
        class_name: 'Post',
        foreign_key: 'referenced_guid',
        primary_key: 'guid'
    end

    # Make sure referenced GUID is stored without protocol
    #
    def referenced_guid=(v)
      write_attribute(:referenced_guid, v.present? ? v.strip.without_http : nil)
    end

    # Returns the referenced post IF it's available in the local
    # database.
    #
    def referenced_post
      Post.where(guid: referenced_guid).includes(:user).first if referenced_guid.present?
    end
  end

  concerning :Pings do
    included do
      has_many :pings,
        dependent: :nullify
    end

    def ping_sources_with_times
      pings.group('source').order('time').pluck('DISTINCT source, min(created_at) AS time')
    end
  end

  class << self
    def [](v)
      find_by(guid: v.without_http)
    end
  end
end
