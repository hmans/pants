class AddUpdatedAtToFriendships < ActiveRecord::Migration
  def change
    add_column :friendships, :updated_at, :datetime
    add_index :friendships, :updated_at
  end
end
