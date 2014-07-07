class AddHiddenToTimelineEntries < ActiveRecord::Migration
  def change
    add_column :timeline_entries, :hidden, :boolean, null: false, default: false
    remove_index :timeline_entries, [:user_id, :created_at]
    add_index :timeline_entries, [:user_id, :hidden, :created_at]
  end
end
