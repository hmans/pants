class DropPgshasFromPosts < ActiveRecord::Migration
  def up
    remove_columns :posts, :pgsha, :previous_shas
  end
end
