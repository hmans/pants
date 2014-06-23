class AddPreviousShasToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :previous_shas, :text, array: true, default: []
    add_index  :posts, :previous_shas, using: 'gin'
  end
end
