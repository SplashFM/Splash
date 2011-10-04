class RemoveAlbumFromTracks < ActiveRecord::Migration
  def self.up
    remove_column :tracks, :album
  end

  def self.down
    add_column :tracks, :album, :string
  end
end
