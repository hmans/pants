class Ability
  include CanCan::Ability

  def initialize(user, site)
    # Everyone!
    #
    can [:read, :day, :tagged], Post
    can [:read, :flair], User, hosted: true

    # Can see the friendships of users who have chosen to
    # make them visible.
    if site.friends_visible?
      can :read, Friendship, user_id: site.id
    end

    # Logged-in users!
    #
    if user.present?
      can :manage, Post, domain: user.domain
      can :manage, TimelineEntry, user_id: user.id
      can :manage, Friendship, user_id: user.id

      # Administrators!
      #
      if user.admin?
        can :manage, :server
        can :manage, User
        can :manage, Ping
      else
        can :manage, User, id: user.id
      end
    end
  end
end
