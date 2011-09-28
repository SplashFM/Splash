class AddTaglineToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :tagline, :string, :limit => 60
  end

  def self.down
    remove_column :users, :tagline
  end
end
