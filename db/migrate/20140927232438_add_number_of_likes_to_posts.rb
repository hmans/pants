class AddNumberOfLikesToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :number_of_likes, :integer, null: false, default: 0
  end
end
