# This service class iterates through all locally known followings and sends
# webmentions to the followed user, allowing them to verify and/or update
# their own information accordingly.
#
class FriendshipReminder < Service
  # How often should a reminder be sent for a single friendship?
  FREQUENCY = 12.hours

  def perform
    if friendship = friendship_to_check
      # Touch the record first. This is to prevent it from being chosen by
      # friendship_to_check over and over again in case of errors, which we
      # currently want to bubble up and result in an exception notification.
      #
      friendship.touch

      # Now send that webmention.
      #
      source = Rails.application.routes.url_helpers.friendships_url(host: friendship.user.domain, d: friendship.friend.domain)
      Webmentioner.perform(source, friendship.friend.url)

      # Return the friendship that we processed.
      #
      friendship
    end
  end

private

  def friendship_to_check
    # We only want to check friendships where the originating user is remote
    # and the friend is local. These friendships are created when receiving
    # Webmentions to the local user's homepage.
    #
    Friendship.joins(:user, :friend)
      .where(users: { hosted: true }, friends_friendships: { hosted: false } )
      .where('friendships.updated_at IS NULL OR friendships.updated_at < ?', FREQUENCY.ago)
      .order('friendships.updated_at').first
  end
end
