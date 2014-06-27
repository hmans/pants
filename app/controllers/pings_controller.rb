class PingsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create]

  def create
    url = params.require(:url)

    if should_fetch?(url)
      # TODO: put this into sidekiq or similar
      if post = Post.fetch_from(url)
        current_site.add_to_timeline(post)
      else
        # TODO: cleaner error handling kthx
        raise "post could not be fetched"
      end
    end

    render nothing: true, status: :accepted
  end

private

  def should_fetch?(url)
    # TODO: check if URL belongs to a friend.
    true
  end
end
