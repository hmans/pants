class AddFromFriendToTimelineEntries < ActiveRecord::Migration
  def change
    add_column :timeline_entries, :from_friend, :boolean, null: false, default: false
  end
end
