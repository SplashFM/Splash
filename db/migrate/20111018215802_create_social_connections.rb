class CreateSocialConnections < ActiveRecord::Migration
  def self.up
    create_table :social_connections do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :token
      t.string :token_secret

      t.timestamps
    end

    add_index :social_connections, :uid, :unique => true
    add_index :social_connections, :user_id
    rename_column :users, :provider, :initial_provider
    remove_column :users, :uid
  end

  def self.down
    remove_index :social_connections, :uid
    remove_index :social_connections, :user_id
    drop_table :social_connections
    rename_column :users, :initial_provider, :provider
    add_column :users, :uid, :string
  end
end
