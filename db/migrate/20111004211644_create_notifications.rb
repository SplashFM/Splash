class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer :notified_id
      t.string :title
      t.datetime :read_at, :default => nil
      t.integer :notifier_id

      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end
