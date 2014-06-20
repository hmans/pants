class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      # SHA
      t.string :sha, limit: 40
      t.string :short_sha, limit: 8
      t.string :successor_sha, limit: 40

      # Data
      t.string :domain
      t.text :body
      t.timestamps
    end
  end
end
