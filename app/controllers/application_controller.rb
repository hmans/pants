class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  respond_to :html

  helper_method :current_site, :current_user

  before_filter do
    I18n.locale = current_site.locale || 'en'
  end

  rescue_from CanCan::AccessDenied do |exception|
    @exception = exception
    render 'error', status: 403
  end

  def current_user
    @current_user ||= begin
      if session[:current_user].present?
        User.find_by!(domain: session[:current_user])
      elsif cookies[:login_user].present? && cookies[:login_domain] == current_site.domain
        user = User.find_by!(domain: cookies[:login_user])
        session[:current_user] = user.domain
        user
      end
    rescue ActiveRecord::RecordNotFound
      logout_user
    end
  end

  def current_site
    @current_site ||= load_current_site
  end

  def load_current_site
    User.hosted.find_by(domain: request.host) or raise "No user/site found for #{request.host}"
  end

  def logout_user
    session[:current_user] = nil
    cookies.delete(:login_user, domain: current_site.domain)
    cookies.delete(:login_domain, domain: current_site.domain)
  end
end
