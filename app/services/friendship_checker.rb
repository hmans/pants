# Checks if friendships across separate servers are still up to date.
#
class FriendshipChecker < Service
  def perform
    if friendship = friendship_to_check
      logger.info "Checking remote friendship between #{friendship.user.domain} and #{friendship.friend.domain}"

      # Check if the rel-following still exists
      RelFollowingChecker.perform(URI.join(friendship.user.url, "/following?d=#{friendship.friend.domain}").to_s)

      # Reload the given friendship; if it wasn't updated, delete it.
      old_updated_at = friendship.updated_at
      friendship.reload
      if friendship.updated_at == old_updated_at
        logger.info "Friendship wasn't updated; assuming it needs to be removed."
        friendship.destroy
      end
    end
  end

private

  def friendship_to_check
    # We only want to check friendships where the originating user is remote
    # and the friend is local. These friendships are created when receiving
    # Webmentions to the local user's homepage.
    #
    Friendship.joins(:user, :friend)
      .where(users: { hosted: false }, friends_friendships: { hosted: true } )
      .where('friendships.updated_at < ?', 6.hours.ago)
      .order('friendships.updated_at').first
  end
end
