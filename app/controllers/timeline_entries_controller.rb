class TimelineEntriesController < ApplicationController
  load_and_authorize_resource :timeline_entry,
    through: :current_site

  def index
    @timeline_entries = @timeline_entries
      .includes(:post)
      .order('created_at DESC')

    unless params[:all]
      @timeline_entries = @timeline_entries.from_friend
    end

    respond_with @timeline_entries
  end
end
