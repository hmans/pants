class FriendshipsController < ApplicationController
  load_and_authorize_resource :friendship,
    through: :current_site

  def index
    @friendships = @friendships.includes(:friend).order('users.domain ASC')
    respond_with @friendships
  end

  def create
    if user = User.fetch_from(params.require(:friend).require(:url))
      @friendship = current_site.add_friend(user)
    end

    respond_with @friendship, location: :friendships
  end

  def destroy
    @friendship.destroy
    respond_with @friendship
  end
end
