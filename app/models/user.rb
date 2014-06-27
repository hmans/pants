class User < ActiveRecord::Base
  has_secure_password validations: false

  validates :domain, :url,
    presence: true,
    uniqueness: true

  has_many :posts,
    foreign_key: 'domain',
    primary_key: 'domain'

  has_many :timeline_entries,
    dependent: :destroy

  before_validation do
    self.url ||= "http://#{domain}/"
  end

  def add_to_timeline(post)
    timeline_entries.where(post_id: post.id).first_or_create!
  end

  class << self
    def fetch_from(url)
      json = HTTParty.get("#{url}/user", query: { format: 'json' })

      # Sanity checks
      full, domain = %r{^https?://(.+)/}.match(url).to_a
      if json['url'] != full || json['domain'] != domain
        raise "User JSON contained corrupted data."
      end

      # Upsert user
      user = where(domain: json['domain']).first_or_initialize
      user.attributes = json
      user.save!

      user
    end
  end
end
