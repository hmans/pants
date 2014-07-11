class Ability
  include CanCan::Ability

  def initialize(user)
    # Everyone!
    #
    can [:read, :day, :tagged], Post
    can [:read, :flair], User, hosted: true

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
