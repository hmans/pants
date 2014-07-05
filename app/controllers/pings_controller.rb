class PingsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create]

  def create
    BackgroundJob.async(PostFetcher.new, :perform,
      params.require(:url), recipient: current_site)

    render nothing: true, status: :accepted
  end
end
