class UsersController < ApplicationController
  respond_to :json, only: :show

  before_filter do
    @user = current_site
  end

  load_and_authorize_resource :user

  def show
    respond_with @user do |format|
      format.jpg do
        job = if @user.image.present?
          @user.image.thumb('300x300#')
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

  def user_params
    params.require(:user).permit(:display_name, :locale, :password, :password_confirmation,
      :image, :remove_image)
  end
end
