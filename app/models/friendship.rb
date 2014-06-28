class Friendship < ActiveRecord::Base
  validates :user_id, :friend_id,
    presence: true

  validate do
    if user.present? && user == friend
      errors.add(:friend, "can't be equal to user")
    end
  end

  belongs_to :user

  belongs_to :friend,
    class_name: 'User',
    foreign_key: 'friend_id'
end
