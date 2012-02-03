class Mention < Notification
  def self.notify(recipient, comment)
    create!(:target   => comment,
            :notifier => comment.author,
            :notified => recipient)
  end

  def title
    I18n.t('notifications.mention', :user => notifier.name)
  end
end
