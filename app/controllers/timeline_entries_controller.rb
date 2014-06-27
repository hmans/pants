class TimelineEntriesController < ApplicationController
  load_and_authorize_resource :timeline_entry,
    through: :current_site

  def index
    @timeline_entries = @timeline_entries.includes(:post).order('created_at DESC')
  end
end
