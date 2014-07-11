class Ping < ActiveRecord::Base
  validates :user_id,
    presence: true

  belongs_to :user
  belongs_to :post

  before_create do
    # Try and find the referenced post by looking it up using
    # the provided target.
    self.post ||= Post[target] if target
  end
end
