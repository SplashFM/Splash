class CommentNotification < Notification
  def self.notify(recipient, comment)
    create!(:target   => comment,
            :notifier => comment.author,
            :notified => recipient)
  end

  def action
    I18n.t('notifications.comment_notification',
           :user => target.splash.user.name)
  end
end
