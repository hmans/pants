# PostPusher accepts a post and pushes it to anyone who may be
# interested, including:
#
# - the author's local & remote friends
# - the author's local followers
#
class PostPusher
  include BackgroundJob

  def perform(post)
    with_appsignal do
      with_database do
        Rails.logger.info "Pushing post #{post.url}..."

        push_to_local_timelines(post)
        ping_friends(post)
      end
    end
  end

  def push_to_local_timelines(post)
    if post.user.present?
      post.user.followers.hosted.find_each do |follower|
        follower.add_to_timeline(post)
      end
    end
  end

  def ping_friends(post)
    if post.user.present?
      post.user.friends.find_each do |friend|
        friend.ping!(url: post.url)
      end
    end
  end
end
