class TimelineEntriesController < ApplicationController
  load_and_authorize_resource :timeline_entry,
    through: :current_site

  def index
    @timeline_entries = @timeline_entries
      .from_friend
      .includes(:post)
      .order('created_at DESC')

    respond_with @timeline_entries
  end
end
