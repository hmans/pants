class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :sha, limit: 40
      t.string :short_sha, limit: 8

      t.text :body

      t.timestamps
    end
  end
end
