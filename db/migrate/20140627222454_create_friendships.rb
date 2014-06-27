class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.belongs_to :user, index: true
      t.belongs_to :friend, index: true
      t.datetime :created_at
    end

    add_index :friendships, [:user_id, :friend_id], unique: true
  end
end
