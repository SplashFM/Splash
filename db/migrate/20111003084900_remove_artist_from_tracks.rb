class RemoveArtistFromTracks < ActiveRecord::Migration
  def self.up
    remove_index :tracks, [:title, :artist]

    remove_column :tracks, :artist

    add_index :tracks, :title
  end

  def self.down
    remove_index :tracks, :title

    add_column :tracks, :artist, :string

    add_index :tracks, [:title, :artist], :unique => true
  end
end
