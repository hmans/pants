class RenameShaColumnOnPosts < ActiveRecord::Migration
  def change
    rename_column :posts, :sha, :pgsha
  end
end
