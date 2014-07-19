class AddGuidsToPings < ActiveRecord::Migration
  def change
    add_column :pings, :source_guid, :string
    add_column :pings, :target_guid, :string
    add_index :pings, [:target_guid, :created_at]
  end
end
