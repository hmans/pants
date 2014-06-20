class Post < ActiveRecord::Base
  validates :body,
    presence: true
end
