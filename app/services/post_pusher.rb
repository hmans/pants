# PostPusher accepts a post and pushes it to anyone who may be
# interested, including:
#
# - the author's local & remote friends
# - the author's local followers
#
class PostPusher
  include Backgroundable

  def initialize(post)
    @post = post
  end

  def push!
    Rails.logger.info "Pushing post #{@post.url}..."

    push_to_local_timelines
    ping_friends
  end

  def push_to_local_timelines
    if @post.user.present?
      @post.user.followers.hosted.find_each do |follower|
        follower.add_to_timeline(@post)
      end
    end
  end

  def ping_friends
    if @post.user.present?
      @post.user.friends.find_each do |friend|
        friend.ping!(url: @post.url)
      end
    end
  end
end
