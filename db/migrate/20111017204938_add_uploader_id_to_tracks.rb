class AddUploaderIdToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :uploader_id, :integer
  end

  def self.down
    remove_column :tracks, :uploader_id
  end
end
