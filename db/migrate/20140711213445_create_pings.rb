class CreatePings < ActiveRecord::Migration
  def change
    create_table :pings do |t|
      t.belongs_to :user
      t.belongs_to :post
      t.string :source
      t.string :target

      t.datetime :created_at
    end

    add_index :pings, [:user_id, :created_at]
    add_index :pings, [:post_id, :created_at]
    add_index :pings, :created_at
  end
end
