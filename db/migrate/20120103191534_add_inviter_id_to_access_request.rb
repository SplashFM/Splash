class AddInviterIdToAccessRequest < ActiveRecord::Migration
  def self.up
    add_column :access_requests, :inviter_id, :integer
  end

  def self.down
    remove_column :access_requests, :inviter_id
  end
end
