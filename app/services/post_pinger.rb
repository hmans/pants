class PostPinger
  def ping!(post)
    post.user.friends.find_each do |friend|
      friend.ping!(url: post.url)
    end
  end
end
