class PostSha < ActiveRecord::Base
  belongs_to :post,
    dependent: :destroy

  validates :sha,
    presence: true,
    uniqueness: true
end