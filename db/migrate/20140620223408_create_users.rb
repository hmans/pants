class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :domain
      t.string :display_name
      t.string :password_digest

      t.timestamps
    end
  end
end
