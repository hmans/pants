class FriendshipsController < ApplicationController
  load_and_authorize_resource :friendship,
    through: :current_site

  def index
    @friendships = @friendships.includes(:friend).order('users.domain ASC')
    respond_with @friendships
  end

  def create
    if user = UserFetcher.new(params.require(:friend).require(:url)).fetch!
      @friendship = current_site.add_friend(user)
    end

    flash[:notice] = t('.success', domain: user.domain)
    respond_with @friendship, location: :friendships
  rescue StandardError => e
    Rails.env.development? ?
      raise :
      redirect_to(:friendships, alert: e.message)
  end

  def destroy
    @friendship.destroy
    flash[:notice] = t('.success', domain: @friendship.friend.domain)
    respond_with @friendship
  end
end
