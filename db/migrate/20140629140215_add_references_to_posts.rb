class AddReferencesToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :referenced_guid, :string
    add_index  :posts, :referenced_guid
  end
end
