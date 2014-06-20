class AuthController < ApplicationController
  def login
    if request.post?
      if user = current_site.authenticate(params[:login][:password])
        session[:current_user] = user.domain
        redirect_to :root and return
      end
    end
  end
end
