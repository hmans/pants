class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  respond_to :html

  helper_method :current_site, :current_user

  def current_user
    nil
  end

  def current_site
    @current_site ||= begin
      User.first
    end
  end
end
