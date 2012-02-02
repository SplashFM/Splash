class AddLocalDataToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :local_data_file_name, :string
    add_column :tracks, :local_data_content_type, :string
    add_column :tracks, :local_data_file_size, :integer
    add_column :tracks, :local_data_updated_at, :datetime
  end

  def self.down
    remove_column :tracks, :local_data_updated_at
    remove_column :tracks, :local_data_file_size
    remove_column :tracks, :local_data_content_type
    remove_column :tracks, :local_data_file_name
  end
end
