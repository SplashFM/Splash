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
    }.uniq

    notifiables.each { |n| Mention.notify n, comment }

    ignorables = notifiables + [comment.author]
    splasher   = comment.splash.user

    unless ignorables.include?(splasher)
      CommentForSplasher.notify splasher, comment
    end

    ignorables << splasher

    (comment.splash.comments.map(&:author).uniq - ignorables).each { |u|
      CommentNotification.notify u, comment
    }
  end
end
