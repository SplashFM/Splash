class CreateGenres < ActiveRecord::Migration
  def self.up
    create_table :genres do |t|
      t.string  :name, :limit => 1000
      t.integer :external_id
      t.string  :source

      t.timestamps
    end
  end

  def self.down
    drop_table :genres
  end
end
