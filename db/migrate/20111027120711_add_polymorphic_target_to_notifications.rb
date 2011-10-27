class AddPolymorphicTargetToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :target_id, :integer
    add_column :notifications, :target_type, :string
  end

  def self.down
    remove_column :notifications, :target_type
    remove_column :notifications, :target_id
  end
end
