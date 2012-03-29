class RestrictSplashing < ActiveRecord::Migration
  def up
    add_index :splashes, [:user_id, :track_id], unique: true
  end

  def down
    remove_index :splashes, [:user_id, :track_id]
  end
end
