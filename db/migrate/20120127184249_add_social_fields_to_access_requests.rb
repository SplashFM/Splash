class AddSocialFieldsToAccessRequests < ActiveRecord::Migration
  def self.up
    add_column :access_requests, :uid, :string
    add_column :access_requests, :provider, :string
  end

  def self.down
    remove_column :access_requests, :provider
    remove_column :access_requests, :uid
  end
end
