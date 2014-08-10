class FriendshipsController < ApplicationController
  load_and_authorize_resource :friendship,
    through: :current_site

  def index
    @friendships = @friendships.includes(:friend).order('users.domain ASC')

    # Allow filtering of a potentially very long list
    if params[:d].present?
      @friendships = @friendships.where(users: { domain: params[:d] })
    end

    respond_with @friendships
  end

  def create
    if user = UserFetcher.perform(params.require(:friend).require(:url))
      @friendship = current_site.add_friend(user)
    end

    # Notify the followed user
    if user.remote? && current_site.friends_visible?
      Webmentioner.async friendships_url(d: user.domain), user.url
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
