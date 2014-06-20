class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Post
    can :create, Post
    can :destroy, Post
    can :update, Post, successor_sha: nil
  end
end
