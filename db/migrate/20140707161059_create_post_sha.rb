class CreatePostSha < ActiveRecord::Migration
  def change
    create_table :post_shas do |t|
      t.belongs_to  :post
      t.string      :sha, limit: 40
      t.datetime    :created_at
    end
  end
end
