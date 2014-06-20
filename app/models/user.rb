class User < ActiveRecord::Base
  has_secure_password

  validates :domain,
    presence: true,
    uniqueness: true

  has_many :posts,
    foreign_key: 'domain',
    primary_key: 'domain'
end
