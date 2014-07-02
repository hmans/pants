class TimelineEntriesController < ApplicationController
  load_and_authorize_resource :timeline_entry,
    through: :current_site

  respond_to :js, only: [:index]

  def index
    @timeline_entries = @timeline_entries
      .includes(:post)
      .order('created_at DESC')
      .limit(20)

    # scrolling
    if params[:before].present?
      @timeline_entries = @timeline_entries.where('id < ?', params[:before])
    end

    @mode = params[:mode] || 'friends'

    case @mode
    when 'all'
    when 'incoming'
      @timeline_entries = @timeline_entries.from_others
    else  # friends only
      @timeline_entries = @timeline_entries.from_friends
    end

    respond_with @timeline_entries
  end
end
