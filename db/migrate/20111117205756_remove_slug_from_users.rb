class RemoveSlugFromUsers < ActiveRecord::Migration
  def self.up
    User.find_each do |u|
      u.update_attribute(:nickname, u.slug)
    end
    remove_column :users, :slug
  end

  def self.down
    add_column :users, :slug, :string

    User.find_each do |u|
      u.update_attribute(:slug, u.nickname)
    end
  end
end
