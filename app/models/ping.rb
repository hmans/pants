class Ping < ActiveRecord::Base
  validates :user_id, :source_guid, :target_guid,
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

  after_create do
    # If this ping is attached to a post, add the source URL
    # to the post's list of referencing URLs.
    #
    if target_post.present? && !target_post.referenced_by.include?(source)
      target_post.referenced_by += [source]
      target_post.save!
    end
  end
end
