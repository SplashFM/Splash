class AddCodeToAccessRequests < ActiveRecord::Migration
  def self.up
    add_column :access_requests, :code, :string
  end

  def self.down
    remove_column :access_requests, :code
  end
end
