class AddNameIndexToGenres < ActiveRecord::Migration
  def self.up
    add_index :genres, :name, :unique => true
  end

  def self.down
    remove_index :genres, :name
  end
end
