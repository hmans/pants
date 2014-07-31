class AddReferencedUrlToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :referenced_url, :string
  end
end
