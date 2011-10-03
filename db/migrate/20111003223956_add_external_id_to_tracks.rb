class AddExternalIdToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :external_id, :integer
  end

  def self.down
    remove_column :tracks, :external_id
  end
end
