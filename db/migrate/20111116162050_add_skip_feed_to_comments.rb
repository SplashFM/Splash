class AddSkipFeedToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :skip_feed, :boolean
  end

  def self.down
    remove_column :comments, :skip_feed
  end
end
