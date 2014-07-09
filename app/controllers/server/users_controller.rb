class Server::UsersController < ServerController
  load_and_authorize_resource :user

  def new
    respond_with @user
  end

  def index
    @users = @users.order('domain')
    respond_with @users
  end

  def create
    @user.password = SecureRandom.urlsafe_base64(15)
    @user.hosted = true
    @user.save

    respond_with @user do |format|
      if @user.valid?
        format.html do
          flash[:random_password] = @user.password
          redirect_to server_user_path(@user)
        end
      end
    end
  end

private

  def user_params
    params.require(:user).permit(:domain)
  end
end
