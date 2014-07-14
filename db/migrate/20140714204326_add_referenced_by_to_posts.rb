class AddReferencedByToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :referenced_by, :text, array: true, default: []
  end
end
