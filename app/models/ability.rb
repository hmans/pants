class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Post
  end
end
