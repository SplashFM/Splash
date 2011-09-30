class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.string  :name, :limit => 1000
      t.string  :artwork_url
      t.integer :external_id
      t.string  :source

      t.timestamps
    end
  end

  def self.down
    drop_table :albums
  end
end
