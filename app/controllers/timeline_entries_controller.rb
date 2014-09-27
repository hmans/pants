class TimelineEntriesController < ApplicationController
  load_and_authorize_resource :timeline_entry,
    through: :current_site

  # Enable AJAX and JSON
  respond_to :js, :json

  before_filter(only: [:index, :incoming]) do
    @timeline_entries = @timeline_entries
      .visible
      .includes(:post)
      .order('timeline_entries.created_at DESC')
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

  def destroy
    @timeline_entry.update_attributes(hidden: true)
    respond_with @timeline_entry
  end

  def hide_all_incoming
    @timeline_entries.from_others
      .where('timeline_entries.created_at <= ?', Time.at(params.require(:until).to_i + 1))
      .update_all(hidden: true)

    redirect_to :network, notice: "All available incoming posts have been hidden."
  end
end
