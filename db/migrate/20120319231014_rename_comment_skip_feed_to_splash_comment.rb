class RenameCommentSkipFeedToSplashComment < ActiveRecord::Migration
  def up
    rename_column :comments, :skip_feed, :splash_comment
  end

  def down
    rename_column :comments, :splash_comment, :skip_feed
  end
end
