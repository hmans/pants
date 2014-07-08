class AddFlairToUsers < ActiveRecord::Migration
  def change
    add_column :users, :flair_uid, :string
  end
end
