class AddTypeToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :type, :string, null: false, default: 'pants.post'
    add_index :posts, [:domain, :type, :published_at]
  end
end
