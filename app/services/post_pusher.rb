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

        if post.user.present?
          # Add post to local followers' timelines
          TimelineManager.new.add_post_to_local_timelines(post)

          # Ping all of the author's friends
          post.user.friends.find_each do |friend|
            friend.ping!(url: post.url)
          end
        end
      end
    end
  end
end
