class UsersController < ApplicationController
  before_filter do
    @user = current_site
  end

  load_and_authorize_resource :user

  def show
    respond_with @user
  end
end
