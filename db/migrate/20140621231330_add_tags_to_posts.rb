class AddTagsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :tags, :text
    add_index  :posts, :tags, length: 1
  end
end
