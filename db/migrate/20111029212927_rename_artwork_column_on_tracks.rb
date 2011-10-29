class RenameArtworkColumnOnTracks < ActiveRecord::Migration
  def self.up
    rename_column :tracks, :album_art_url, :artwork_url
  end

  def self.down
    rename_column :tracks, :artwork_url, :album_art_url
  end
end
