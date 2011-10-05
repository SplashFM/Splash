class AddPreviewUrlToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :preview_url, :string
  end

  def self.down
    remove_column :tracks, :preview_url
  end
end
