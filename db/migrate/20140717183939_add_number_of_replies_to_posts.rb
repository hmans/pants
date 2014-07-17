class AddNumberOfRepliesToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :number_of_replies, :integer, null: false, default: 0
  end
end
