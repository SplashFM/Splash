class CreateTrack < ActiveRecord::Migration
  def self.up
    create_table :tracks, :force => true do |t|
      t.string :title, :null => false
      t.string :album
      t.string :artist, :null => false

      t.timestamps
    end

    add_index :tracks, [:title, :artist], :unique => true
  end

  def self.down
    remove_index :tracks, [:title, :artist]

    drop_table :tracks
  end
end
