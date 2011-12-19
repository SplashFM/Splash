class CreateAccessRequests < ActiveRecord::Migration
  def self.up
    create_table :access_requests do |t|
      t.string :email
      t.boolean :granted

      t.timestamps
    end
  end

  def self.down
    drop_table :access_requests
  end
end
