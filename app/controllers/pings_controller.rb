class PingsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create]

  def create
    url = params.require(:url)
    PostFetcher.perform_async(url, recipient: current_site)
    render nothing: true, status: :accepted
  end
end
