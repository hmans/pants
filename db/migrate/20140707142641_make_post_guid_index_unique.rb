class MakePostGuidIndexUnique < ActiveRecord::Migration
  def change
    remove_index :posts, :guid
    add_index :posts, :guid, unique: true
  end
end
