class RemoveSuccessorFromPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :successor_sha
  end
end
