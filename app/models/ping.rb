class Ping < ActiveRecord::Base
  validates :user_id,
    presence: true

  belongs_to :user

  belongs_to :source_post,
    class_name: 'Post',
    foreign_key: 'source_guid',
    primary_key: 'guid'

  belongs_to :target_post,
    class_name: 'Post',
    foreign_key: 'target_guid',
    primary_key: 'guid'

  before_validation do
    self.source_guid = source.try(:to_guid)
    self.target_guid = target.try(:to_guid)
  end
end
