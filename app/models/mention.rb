class Mention < Notification
  def self.notify(comment)
    comment.mentioned_users.each { |recipient|
      if recipient.following?(comment.author)
        create!(:target   => comment,
                :notifier => comment.author,
                :notified => recipient)
      end
    }
  end

  def title
    I18n.t('notifications.mention', :user => notifier.name)
  end
end
