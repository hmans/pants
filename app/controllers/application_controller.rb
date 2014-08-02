class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #
  protect_from_forgery with: :null_session

  # By default, only respond to HTML requests.
  #
  respond_to :html

  # Note some extra data to be recorded by lograge.
  #
  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
  end

  concerning :ErrorHandling do
    included do
      rescue_from ActiveRecord::RecordNotFound, with: :render_404

      rescue_from CanCan::AccessDenied do |exception|
        @error = exception.message
        @page_title = "Error"

        respond_to do |format|
          format.html { render 'error', status: 403, formats: [:html] }
          format.json { render json: { error: 'Unauthorized' }, status: 403 }
        end
      end
    end

    def render_404
      @error = "Not found. I'm sorry."
      @page_title = "Not Found"
      render 'error', status: 404, formats: [:html]
    end
  end

  before_filter do
    if current_site.blank?
      if Rails.env.production?
        redirect_to ENV['PANTS_FALLBACK_URL'] || User.first.domain.with_http
      else
        # Enable host-less development access
        @current_site = User.first
      end
    elsif current_site.domain != request.host
      redirect_to(host: current_site.domain, status: 302)
    end
  end

  before_filter do
    I18n.locale = current_site.locale || 'en'
  end

  def discovery
    # Renders some JSON with information relevant to API clients.
    respond_to do |format|
      format.json {}
    end
  end

  concerning :CurrentUser do
    included do
      helper_method :current_user
    end

    def current_user
      @current_user ||= begin
        if session[:current_user].present?
          User.find_by!(domain: session[:current_user])
        elsif params[:token].present?
          data = ApiTokens.verify(params[:token])
          if current_site.id == data[:site] && Time.now < data[:expires]
            User.find(data[:user])
          else
            raise "Invalid API token"
          end
        elsif cookies[:login_user].present? && cookies[:login_domain] == current_site.domain
          user = User.find_by!(domain: cookies[:login_user])
          session[:current_user] = user.domain
          user
        end
      rescue ActiveRecord::RecordNotFound
        logout_user
      end
    end

    def logout_user
      session[:current_user] = nil
      cookies.delete(:login_user, domain: current_site.domain)
      cookies.delete(:login_domain, domain: current_site.domain)
    end
  end

  concerning :CurrentSite do
    included do
      helper_method :current_site
    end

    def current_site
      @current_site ||= load_current_site
    end

    def load_current_site
      parts = request.subdomains + [request.domain]
      while parts.any? && (site = User.hosted.find_by(domain: parts.join('.'))).nil?
        parts.shift
      end

      site
    end
  end

  concerning :PageTitle do
    included do
      attr_writer :page_title
      helper_method :page_title, :page_title=
    end

    def page_title
      @page_title ||= t(".page_title", default: '')
    end
  end

  concerning :CanonicalUrls do
    def with_canonical_url(url)
      if request.url != url
        flash.keep
        redirect_to(url, status: 301)
      else
        yield
      end
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, current_site)
  end
end
