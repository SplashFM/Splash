class AddReferralCodeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :referral_code, :string
  end

  def self.down
    remove_column :users, :referral_code
  end
end
