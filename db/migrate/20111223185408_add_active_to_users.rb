class AddActiveToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :active, :boolean

    execute "update users set active = true"
  end

  def self.down
    remove_column :users, :active
  end
end
