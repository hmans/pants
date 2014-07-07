require 'html/sanitizer'

class Post < ActiveRecord::Base
  # Scopes
  #
  scope :on_date, ->(date) { where(published_at: (date.at_beginning_of_day)..(date.at_end_of_day)) }
  scope :latest, -> { order('published_at DESC') }
  scope :referencing, ->(guid) { where("? = ANY(posts.references)", guid) }

  # Validations
  #
  before_validation do
    if body_changed?
      # Resolve hashtag links
      body_with_hashtags = body.gsub(TagExtractor::REGEX) do
        "<a href=\"#{user.try(:url)}/tag/#{$1.downcase}\" class=\"hashtag\">##{$1}</a>"
      end

      # Render body to HTML
      self.body_html = Formatter.new(body_with_hashtags).complete.to_s
    end

    # Extract and save tags
    self.tag_list.add TagExtractor.extract_tags(HTML::FullSanitizer.new.sanitize(body_html)).map(&:downcase)

    # Generate slug
    self.slug ||= generate_slug

    # Set GUID
    self.guid = "#{domain}/#{slug}"

    # Publish post right away... for now
    self.published_at ||= Time.now     # for the SHA

    # Default editing timestamp to publishing timestamp
    self.edited_at ||= published_at

    # Default URL to http://<guid>
    self.url ||= "http://#{guid}"

    # Update SHAs
    self.shas.build sha: calculate_sha unless self.shas.find_by(sha: calculate_sha)
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

  acts_as_taggable

  belongs_to :user,
    foreign_key: 'domain',
    primary_key: 'domain'

  has_many :timeline_entries,
    dependent: :destroy

  has_many :shas,
    class_name: PostSha,
    autosave: true,
    dependent: :destroy

  def sha
    self.shas.last().try(:sha)
  end

  def calculate_sha
    Digest::SHA1.hexdigest("pants:#{guid}:#{referenced_guid}:#{body}")
  end

  def previous_shas
    self.shas.order(id: :asc).all.slice(0...-1).map(&:sha)
  end

  def generate_slug
    chars = ('a'..'z').to_a
    numbers = (0..9).to_a

    (Array.new(3) { chars.sample } + Array.new(3) { numbers.sample }).join('')
  end

  concerning :Representation do
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

  class << self
    # The following attributes will be copied from post JSON responses
    # into local Post instances.
    #
    ACCESSIBLE_JSON_ATTRIBUTES = %w{
      guid
      url
      published_at
      edited_at
      referenced_guid
      body
      body_html
      domain
      slug
      sha
      previous_shas
      tags
    }

    def from_json!(json)
      # Upsert post
      post = transaction do
        post = where(guid: json['guid']).first_or_initialize
        if post.new_record? || post.edited_at < json['edited_at']
          post.attributes = json.slice(*ACCESSIBLE_JSON_ATTRIBUTES)
          post.save!
        end

        post
      end

      # Upsert the post's author
      author_url = post.url.scan(%r{^https?://.+?/}).first
      User.fetch_from(author_url)

      post
    end

    def [](v)
      find_by(guid: v)
    end
  end
end
