class AddLastPolledAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_polled_at, :datetime
    add_index :users, :last_polled_at
  end
end
