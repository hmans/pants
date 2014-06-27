class AddGoSquaredIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gosquared_id, :string, limit: 20
  end
end
