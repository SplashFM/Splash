class AddReferralCodeToAccessRequests < ActiveRecord::Migration
  def self.up
    add_column :access_requests, :referral_code, :string
  end

  def self.down
    remove_column :access_requests, :referral_code
  end
end
