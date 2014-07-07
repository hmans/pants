class TimelineEntriesController < ApplicationController
  load_and_authorize_resource :timeline_entry,
    through: :current_site

  # Also respond to AJAX requests
  respond_to :js

  before_filter(only: [:index, :incoming]) do
    @timeline_entries = @timeline_entries
      .includes(:post)
      .order('created_at DESC')
      .limit(20)
  end

  def index
    @timeline_entries = @timeline_entries.from_friends
    respond_with @timeline_entries
  end

  def incoming
    @timeline_entries = @timeline_entries.from_others
    respond_with @timeline_entries
  end
end
