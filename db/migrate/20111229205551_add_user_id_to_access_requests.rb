class AddUserIdToAccessRequests < ActiveRecord::Migration
  def self.up
    add_column :access_requests, :user_id, :integer
  end

  def self.down
    remove_column :access_requests, :user_id
  end
end
