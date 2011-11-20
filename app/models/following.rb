class Following < Notification
  def self.notify(relationship)
    create! :notified => relationship.followed,
            :notifier => relationship.follower
  end

  def title
    I18n.t('notifications.following',
           :user => notifier.name)
  end
end
