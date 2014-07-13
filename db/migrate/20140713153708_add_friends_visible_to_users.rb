class AddFriendsVisibleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :friends_visible, :boolean, null: false, default: true
  end
end
