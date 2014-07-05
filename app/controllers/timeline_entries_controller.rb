class TimelineEntriesController < ApplicationController
  load_and_authorize_resource :timeline_entry,
    through: :current_site

  respond_to :js, only: [:index]

  before_filter(only: [:index, :incoming]) do
    @timeline_entries = @timeline_entries
      .includes(:post)
      .order('created_at DESC')
      .limit(20)

    # scrolling
    if params[:before].present?
      @timeline_entries = @timeline_entries.where('id < ?', params[:before])
    end
  end

  def index
    @timeline_entries = @timeline_entries.from_friends

    respond_with @timeline_entries
  end

  def incoming
    @timeline_entries = @timeline_entries.from_others
    render 'index'
  end
end
