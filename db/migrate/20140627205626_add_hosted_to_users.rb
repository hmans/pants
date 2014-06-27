class AddHostedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hosted, :boolean, null: false, default: false
  end
end
