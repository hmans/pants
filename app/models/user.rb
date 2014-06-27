class User < ActiveRecord::Base
  has_secure_password

  validates :domain,
    presence: true,
    uniqueness: true

  has_many :posts,
    foreign_key: 'domain',
    primary_key: 'domain'

  has_many :timeline_entries,
    dependent: :destroy

  def add_to_timeline(post)
    timeline_entries.where(post_id: post.id).first_or_create!
  end
end
