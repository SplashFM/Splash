class AddCommentToSplashes < ActiveRecord::Migration
  def self.up
    add_column :splashes, :comment, :string
  end

  def self.down
    remove_column :splashes, :comment
  end
end
