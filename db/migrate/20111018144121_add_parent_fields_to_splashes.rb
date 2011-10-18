class AddParentFieldsToSplashes < ActiveRecord::Migration
  def self.up
    add_column :splashes, :parent_id, :integer
    add_column :splashes, :splash_list, :string
    add_column :splashes, :user_list, :string

    add_index :splashes, :parent_id
  end

  def self.down
    remove_index :splashes, :parent_id

    remove_column :splashes, :user_list
    remove_column :splashes, :splash_list
    remove_column :splashes, :parent_id
  end
end
