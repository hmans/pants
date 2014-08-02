class PingsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create]

  def create
    # :source is from webmention, :url is legacy pants-style
    source = params[:source] || params[:url]
    target = params[:target]

    # Create Ping instance
    current_site.pings.create!(source: source, target: target)

    # Defer to WebmentionHandler
    WebmentionHandler.async(current_site, source, target)

    # Pretend like nothing happened
    render nothing: true, status: :accepted
  end
end
