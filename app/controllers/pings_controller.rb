class PingsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create]

  def create
    # :source is from webmention, :url is legacy pants-style
    url = params[:source] || params[:url]
    target = params[:target]

    # Create Ping instance
    current_site.pings.create!(source: url, target: target)

    # Fetch that post!
    PostFetcher.new(url, recipient: current_site).async.fetch!

    # Pretend like nothing happened
    render nothing: true, status: :accepted
  end
end
