class RemoveCommentFromSplashes < ActiveRecord::Migration
  def self.up
    remove_column :splashes, :comment
  end

  def self.down
    add_column :splashes, :comment, :string
  end
end
