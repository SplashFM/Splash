class AddSuggestedUsersToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :suggested_users, :text
  end

  def self.down
    remove_column :users, :suggested_users
  end
end
