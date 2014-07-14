class DropShaColumnsFromPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :sha
    remove_column :posts, :previous_shas
  end
end
