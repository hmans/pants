# PostPinger accepts a post and then pings all of its author's
# friends. Note that we're pinging even local friends -- this is
# because 1) we may not know a previously hosted friend has moved
# their domain to a new server, and 2) pings will eventually be
# made visible in some kind of new notifications timeline.
#
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
