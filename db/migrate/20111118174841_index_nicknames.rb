class IndexNicknames < ActiveRecord::Migration
  def self.up
    add_index :users, :nickname, :unique => true
  end

  def self.down
    remove_index :users, :nickname
  end
end
