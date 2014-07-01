class AuthController < ApplicationController
  def login
    if request.post?
      if user = current_site.authenticate(params[:login][:password])
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

        redirect_to :root and return
      end
    end
  end
end
