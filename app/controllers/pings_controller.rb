class PingsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create]

  def create
    url = params.require(:url)
    PostFetcher.new(url, recipient: current_site).async.fetch!
    render nothing: true, status: :accepted
  end
end
