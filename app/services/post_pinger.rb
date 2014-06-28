class PostPinger
  include SuckerPunch::Job

  def perform(post_id)
    ActiveRecord::Base.connection_pool.with_connection do
      post = Post.find(post_id)
      post.user.friends.find_each do |friend|
        Rails.logger.info "Pinging #{friend.url} with post #{post.url}"
        friend.ping!(url: post.url)
      end
    end
  end
end
