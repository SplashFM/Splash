class AddIgnoreSuggestedUsersToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :ignore_suggested_users, :text
  end

  def self.down
    remove_column :users, :ignore_suggested_users
  end
end
