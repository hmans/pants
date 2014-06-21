class Ability
  include CanCan::Ability

  def initialize(user)
    can [:read, :day], Post

    if user.present?
      can :create, Post, domain: user.domain
      can :destroy, Post, domain: user.domain
      can :update, Post, domain: user.domain, successor_sha: nil

      can :manage, user
    end
  end
end
