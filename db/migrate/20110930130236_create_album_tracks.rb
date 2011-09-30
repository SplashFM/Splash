class CreateAlbumTracks < ActiveRecord::Migration
  def self.up
    create_table :album_tracks, :id => false do |t|
      t.references :album
      t.references :track
    end
  end

  def self.down
    drop_table :album_tracks
  end
end
