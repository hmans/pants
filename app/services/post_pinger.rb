class PostPinger
  include BackgroundJob

  def perform(post)
    with_appsignal do
      with_database do
        post.user.friends.find_each do |friend|
          friend.ping!(url: post.url)
        end
      end
    end
  end
end
