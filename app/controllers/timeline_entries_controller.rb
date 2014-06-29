class TimelineEntriesController < ApplicationController
  load_and_authorize_resource :timeline_entry,
    through: :current_site

  def index
    @timeline_entries = @timeline_entries
      .includes(:post)
      .order('created_at DESC')

    case params[:mode]
    when 'all'
    when 'others'
      @timeline_entries = @timeline_entries.from_others
    else  # friends only
      @timeline_entries = @timeline_entries.from_friends
    end

    respond_with @timeline_entries
  end
end
