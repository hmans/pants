class CreateTimelineEntries < ActiveRecord::Migration
  def change
    create_table :timeline_entries do |t|
      t.belongs_to :user, index: true
      t.belongs_to :post, index: true
      t.datetime :created_at
    end

    add_index :timeline_entries, [:user_id, :created_at]
    add_index :timeline_entries, [:user_id, :post_id], unique: true
  end
end
