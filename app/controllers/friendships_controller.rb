class FriendshipsController < ApplicationController
  load_and_authorize_resource :friendship,
    through: :current_site

  def index
    @friendships = @friendships.includes(:friend).order('users.domain ASC')
    respond_with @friendships
  end

  def create
    if user = UserFetcher.perform(params.require(:friend).require(:url))
      @friendship = current_site.add_friend(user)
    end

    flash[:notice] = "#{user.domain} has been added to your friends."
    respond_with @friendship, location: :friendships
  rescue StandardError => e
    Rails.env.development? ?
      raise :
      redirect_to(:friendships, alert: e.message)
  end

  def destroy
    @friendship.destroy
    flash[:notice] = "#{@friendship.friend.domain} has been removed from your friends."
    respond_with @friendship
  end
end
