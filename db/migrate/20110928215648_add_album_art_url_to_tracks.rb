class AddAlbumArtUrlToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :album_art_url, :string
  end

  def self.down
    remove_column :tracks, :album_art_url
  end
end
