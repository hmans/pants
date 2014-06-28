class PostFetcher
  include SuckerPunch::Job

  def perform(url, user_id = nil)
    ActiveRecord::Base.connection_pool.with_connection do
      if should_fetch?(url)
        post = Post.fetch_from(url)

        if post && user_id
          user = User.find(user_id)
          user.add_to_timeline(post)
        end
      end
    end
  end

private

  def should_fetch?(url)
    # TODO: check if URL belongs to a friend.
    true
  end
end
