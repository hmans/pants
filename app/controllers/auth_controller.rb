class AuthController < ApplicationController
  def login
    if request.post?
      if user = current_site.authenticate(params[:login][:password])
        respond_to do |format|
          format.html do
            session[:current_user] = user.domain

            # remember me?
            if params[:login][:remember_me] == '1'
              defaults = { expires: 3.months.from_now, domain: current_site.domain }

              # Remember both the user who's logging in as well as the domain they're
              # logging in to -- just in case the cookie ever gets leaked to a subdomain
              # or something similarly stupid.

              cookies[:login_user]   = defaults.merge(value: user.domain)
              cookies[:login_domain] = defaults.merge(value: current_site.domain)
            end

            redirect_to :root
          end

          format.json do
            token = ApiTokens.generate(user, current_site)
            render json: { token: token }
          end
        end

        return
      end
    end
  end

  def logout
    logout_user
    redirect_to :root, notice: "You've been logged out. See you later!"
  end

  def generate_api_token
    'abc'
  end
end
