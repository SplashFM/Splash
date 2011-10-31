class AddExternalIdToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :external_id, :integer
  end

  def self.down
    remove_column :tags, :external_id
  end
end
