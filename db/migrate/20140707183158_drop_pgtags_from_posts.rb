class DropPgtagsFromPosts < ActiveRecord::Migration
  def up
    remove_column :posts, :pgtags
  end
end
