class AddIndicesToUsers < ActiveRecord::Migration
  def change
    add_index :users, [:hosted, :domain]
    add_index :users, :domain, unique: true
  end
end
