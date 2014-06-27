class AddEditedAtToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :edited_at, :datetime
  end
end
