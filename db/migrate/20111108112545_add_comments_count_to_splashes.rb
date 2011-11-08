class AddCommentsCountToSplashes < ActiveRecord::Migration
  def self.up
    add_column :splashes, :comments_count, :integer

    execute "update splashes
             set comments_count = (select count(*)
                                   from comments
                                   where splash_id = splashes.id)"
  end

  def self.down
    remove_column :splashes, :comments_count
  end
end
