class AddGuidToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :guid, :string
    add_index :posts, :guid
  end
end
