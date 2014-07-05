class PostPinger
  include SuckerPunch::Job

  def perform(post)
    ActiveRecord::Base.connection_pool.with_connection do
      post.user.friends.find_each do |friend|
        friend.ping!(url: post.url)
      end
    end
  end
end
