class ReplaceShortShaWithSlugInPosts < ActiveRecord::Migration
  def change
    rename_column :posts, :short_sha, :slug
    change_column :posts, :slug, :string
  end
end
