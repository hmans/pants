class RemoveReferencedByFromPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :referenced_by
  end
end
