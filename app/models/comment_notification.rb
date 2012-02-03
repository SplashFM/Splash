class CommentNotification < Notification
  def self.notify(recipient, comment)
    create!(:target   => comment,
            :notifier => comment.author,
            :notified => recipient)
  end
end