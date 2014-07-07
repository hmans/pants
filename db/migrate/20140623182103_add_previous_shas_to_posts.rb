class AddPreviousShasToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :previous_shas, :text
    add_index  :posts, :previous_shas, length: 1
  end
end
