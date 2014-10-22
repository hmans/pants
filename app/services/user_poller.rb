class UserPoller < Service
  def perform(domain)
    raise "no domain specified" if domain.blank?
    raise "domain must be a string" unless domain.is_a?(String)

    user = User[domain]
    raise "user not found" if user.blank?

    # First, update the user.
    UserFetcher.perform(user.url) if user.updated_at < 1.hour.ago

    # Never poll for hosted users.
    unless user.hosted? || user.followings.empty?
      last_polled_at = user.last_polled_at
      user.update_column(:last_polled_at, Time.now)  # `touch` would update updated_at :(

      posts_url = URI.join(user.url, '/posts.json').to_s
      posts_json = HTTP.get(posts_url,
        query: { updated_since: last_polled_at.try(:to_i) },
        verify: false)

      if posts_json.content_type != 'application/json'
        logger.warn "#{user.domain} didn't correctly serve /posts.json"
        # TODO: mark the user as "broken"
        return nil
      else
        # upsert posts in the database
        posts = posts_json.reverse.map do |json|
          PostUpserter.perform(json, posts_url)
        end.compact

        # add posts to local followers' timelines
        user.followings.includes(:user).each do |friendship|
          posts.each do |post|
            if friendship.created_at <= post.edited_at
              friendship.user.add_to_timeline(post)
            end
          end
        end

        # Return posts fetched.
        posts
      end
    end

  rescue SocketError => e
    logger.error "Could not poll user: #{e}"
    nil
  end
end
