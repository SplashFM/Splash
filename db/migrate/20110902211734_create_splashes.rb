class CreateSplashes < ActiveRecord::Migration
  def self.up
    create_table :splashes do |t|
      t.integer :track_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :splashes
  end
end
