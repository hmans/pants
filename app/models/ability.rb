class Ability
  include CanCan::Ability

  def initialize(user)
    can [:read, :day], Post
    can :read, User

    if user.present?
      can :manage, Post, domain: user.domain
      can :manage, user

      can :manage, TimelineEntry, user_id: user.id
      can :manage, Friendship, user_id: user.id
    end
  end
end
