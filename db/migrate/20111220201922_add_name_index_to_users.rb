class AddNameIndexToUsers < ActiveRecord::Migration
  def self.up
    execute "CREATE INDEX index_users_lower_name ON users(lower(name))"
  end

  def self.down
    execute "DROP INDEX index_users_lower_name"
  end
end
