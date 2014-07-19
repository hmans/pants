class RemovePostIdFromPings < ActiveRecord::Migration
  def change
    remove_column :pings, :post_id
  end
end
