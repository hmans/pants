require 'html/sanitizer'

class Post < ActiveRecord::Base
  before_validation do
    # Render body to HTML
    self.body_html = Formatter.new(body).complete.to_s

    # Extract and save tags
    self.tags = TagExtractor.extract_tags(HTML::FullSanitizer.new.sanitize(body_html))

    # Update SHAs
    self.published_at ||= Time.now     # for the SHA
    self.sha = calculate_sha
    self.slug ||= generate_slug
  end

  before_update do
    # Remember previous SHA
    if sha_changed? && sha_was.present? && !sha_was.in?(previous_shas)
      self.previous_shas += [sha_was]
    end
  end

  validates :body,
    presence: true

  validates :sha, :slug,
    presence: true,
    uniqueness: true

  belongs_to :user,
    foreign_key: 'domain',
    primary_key: 'domain'

  scope :on_date, ->(date) { where(created_at: (date.at_beginning_of_day)..(date.at_end_of_day)) }
  scope :latest, -> { order('created_at DESC') }
  scope :tagged_with, ->(tag) { where("tags @> ARRAY[?]", tag) }

  def calculate_sha
    Digest::SHA1.hexdigest("pants:#{domain}:#{published_at.try(:iso8601)}:#{body}")
  end

  def generate_slug
    rand(36**8).to_s(36)
  end

  def to_param
    slug
  end
end
