class AddMetadataToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :performers, :text
    add_column :tracks, :albums, :text
    add_column :tracks, :album_artwork_url, :string
  end

  def self.down
    remove_column :tracks, :album_artwork_url
    remove_column :tracks, :albums
    remove_column :tracks, :performers
  end
end
