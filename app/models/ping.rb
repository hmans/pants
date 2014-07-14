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

  after_create do
    # If this ping is attached to a post, add the source URL
    # to the post's list of referencing URLs.
    #
    if post.present? && !post.referenced_by.include?(source)
      post.referenced_by += [source]
      post.save!
    end
  end
end
