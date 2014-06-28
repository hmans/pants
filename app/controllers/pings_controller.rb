class PingsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create]

  def create
    PostFetcher.new.async.perform(params.require(:url), current_site.id)
    render nothing: true, status: :accepted
  end
end
