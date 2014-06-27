require 'html/sanitizer'

class Post < ActiveRecord::Base
  before_validation do
    if body_changed?
      # Render body to HTML
      self.body_html = Formatter.new(body).complete.to_s

      # Update editing timestamp
      self.edited_at = Time.now
    end

    # Extract and save tags
    self.tags = TagExtractor.extract_tags(HTML::FullSanitizer.new.sanitize(body_html)).map(&:downcase)

    # Generate slug
    self.slug ||= generate_slug

    # Set GUID
    self.guid = "#{domain}/#{slug}"

    # Publish post right away... for now
    self.published_at ||= Time.now     # for the SHA

    # Default URL to http://<guid>
    self.url ||= "http://#{guid}"

    # Update SHAs
    self.sha = calculate_sha
  end

  before_update do
    # Remember previous SHA
    if sha_changed? && sha_was.present? && !sha_was.in?(previous_shas)
      self.previous_shas += [sha_was]
    end
  end

  validate(on: :update) do
    if guid_changed?
      errors.add(:guid, "can not be changed.")
    end

    # TODO: check that URL matches GUID
  end

  validates :body,
    presence: true

  validates :sha, :slug,
    presence: true,
    uniqueness: true

  belongs_to :user,
    foreign_key: 'domain',
    primary_key: 'domain'

  has_many :timeline_entries,
    dependent: :destroy

  scope :on_date, ->(date) { where(created_at: (date.at_beginning_of_day)..(date.at_end_of_day)) }
  scope :latest, -> { order('created_at DESC') }
  scope :tagged_with, ->(tag) { where("tags @> ARRAY[?]", tag) }

  def calculate_sha
    Digest::SHA1.hexdigest("pants:#{guid}:#{body}")
  end

  def generate_slug
    chars = ('a'..'z').to_a
    numbers = (0..9).to_a

    (Array.new(3) { chars.sample } + Array.new(3) { numbers.sample }).join('')
  end

  def to_param
    slug
  end

  class << self
    def fetch_from(url)
      json = HTTParty.get(url)

      post = where(guid: json['guid']).first_or_initialize
      if post.new_record? || post.edited_at < json['edited_at']
        post.attributes = json
        # TODO: check if GUID/domain/slug match requested URL
        post.save!
      end

      post
    end
  end
end
