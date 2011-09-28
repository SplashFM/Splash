class AddPurchaseUrlToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :purchase_url_raw, :string, :limit => 1024
  end

  def self.down
    remove_column :tracks, :purchase_url_raw
  end
end
