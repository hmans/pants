class AddLocaleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :locale, :string, limit: 5, default: 'en', null: 'false'
  end
end
