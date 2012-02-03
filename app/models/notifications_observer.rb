class NotificationsObserver < ActiveRecord::Observer
  observe :relationship, :comment

  def after_create(target)
    send "notify_#{target.class.name.underscore}", target
  end

  private

  def notify_relationship(relationship)
    Following.notify relationship
  end

  def notify_comment(comment)
    notifiables = comment.mentioned_users.select { |u|
      u.following?(comment.author)
    }

    notifiables.each { |n| Mention.notify n, comment }

    splasher = comment.splash.user

    if comment.author != splasher
      CommentForSplasher.notify splasher, comment
    end
  end
end
