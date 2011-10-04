class RemoveAllTrackRelatedIndexes < ActiveRecord::Migration
  def self.up
    remove_index :genres, :name
    remove_index :tracks, :title
  end

  def self.down
    add_index :genres, :name
    add_index :tracks, :title
  end
end
