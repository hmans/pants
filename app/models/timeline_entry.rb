class TimelineEntry < ActiveRecord::Base
  validates_presence_of :user_id, :post_id

  belongs_to :user
  belongs_to :post

  scope :from_friends, -> { where(from_friend: true) }
  scope :from_others,  -> { where(from_friend: false) }
end
