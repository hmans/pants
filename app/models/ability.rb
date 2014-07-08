class Ability
  include CanCan::Ability

  def initialize(user)
    can [:read, :day, :tagged], Post
    can [:read, :flair], User

    if user.present?
      can :manage, Post, domain: user.domain
      can :manage, User, id: user.id

      can :manage, TimelineEntry, user_id: user.id
      can :manage, Friendship, user_id: user.id
    end
  end
end
