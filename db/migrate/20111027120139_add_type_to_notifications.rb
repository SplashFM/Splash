class AddTypeToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :type, :string
  end

  def self.down
    remove_column :notifications, :type
  end
end
