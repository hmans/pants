class AddWebLinksToUsers < ActiveRecord::Migration
  def change
    add_column :users, :web_links, :text, default: [], array: true
  end
end
