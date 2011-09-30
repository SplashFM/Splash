class CreateTrackGenres < ActiveRecord::Migration
  def self.up
    create_table :track_genres, :id => false do |t|
      t.references :track
      t.references :genre
    end
  end

  def self.down
    drop_table :track_genres
  end
end
