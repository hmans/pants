class PingsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create]

  def create
    url = params.require(:url)

    # Fetch the references post asynchroneously.
    # TODO: check if we really need to do this, since this server may
    #       already have received multiple pings for the same post.
    PostFetcher.perform_async(url, recipient: current_site)

    render nothing: true, status: :accepted
  end
end
