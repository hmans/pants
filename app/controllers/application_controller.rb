class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  respond_to :html, :json

  helper_method :current_site, :current_user

  before_filter do
    I18n.locale = current_site.locale || 'en'
  end

  def current_user
    @current_user ||= begin
      if session[:current_user].present?
        User.find_by!(domain: session[:current_user])
      end
    rescue ActiveRecord::RecordNotFound
      session[:current_user] = nil
    end
  end

  def current_site
    @current_site ||= load_current_site
  end

  def load_current_site
    User.find_by(domain: request.host) or raise "No user/site found for #{request.host}"
  end
end
