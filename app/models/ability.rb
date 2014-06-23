class Ability
  include CanCan::Ability

  def initialize(user)
    can [:read, :day], Post

    if user.present?
      can :manage, Post, domain: user.domain
      can :manage, user
    end
  end
end
