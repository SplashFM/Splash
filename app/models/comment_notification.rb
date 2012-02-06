class CommentNotification < Notification
  def self.notify(recipient, comment)
    create!(:target   => comment,
            :notifier => comment.author,
            :notified => recipient)
  end

  def template
    'comment_notification'
  end

  def as_json(options = {})
    super(options).merge!(:splash_id => target.splash_id)
  end
end
