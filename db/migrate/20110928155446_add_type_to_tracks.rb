class AddTypeToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :type, :string
  end

  def self.down
    remove_column :tracks, :type
  end
end
