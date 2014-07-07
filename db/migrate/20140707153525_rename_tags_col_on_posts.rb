class RenameTagsColOnPosts < ActiveRecord::Migration
  def change
    remove_index :posts, :tags
    rename_column :posts, :tags, :pgtags
  end
end
