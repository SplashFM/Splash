class CreateTrackPerfomers < ActiveRecord::Migration
  def self.up
    create_table :track_performers, :id => false do |t|
      t.references :track
      t.references :artist
    end
  end

  def self.down
    drop_table :track_performers
  end
end
