class AddDataToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :data, :json
  end
end
