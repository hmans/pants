class UsersController < ApplicationController
  respond_to :json, only: :show

  # This is a singleton resource, and the user we're dealing with
  # is always the current site.
  #
  before_filter do
    @user = current_site
  end

  load_and_authorize_resource :user

  def show
    respond_with @user do |format|
      format.css { }
      format.jpg do
        job = if @user.image.present?
          @user.local_thumbnail
        else
          Dragonfly.app.generate(:plain, 1, 1,
            'format' => 'png',
            'color' => 'rgba(0,0,0,0)')
        end

        redirect_to job.url
      end
    end
  end

  def edit
    respond_with @user
  end

  def update
    @user.update_attributes(user_params)
    respond_with @user, location: :root
  end

  def flair
    respond_to do |format|
      format.jpg do
        job = if @user.flair.present?
          @user.local_cropped_flair
        else
          Dragonfly.app.generate(:plain, 1, 1,
            'format' => 'png',
            'color' => 'rgba(0,0,0,0)')
        end

        redirect_to job.url
      end
    end
  end

private

  def user_params
    params.require(:user).permit(:display_name, :locale, :password, :password_confirmation,
      :image, :remove_image, :flair, :remove_flair)
  end
end
