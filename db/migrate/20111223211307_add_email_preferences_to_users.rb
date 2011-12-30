class AddEmailPreferencesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email_preferences, :text
  end

  def self.down
    remove_column :users, :email_preferences
  end
end
