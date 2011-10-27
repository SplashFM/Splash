class Following < Notification
  def self.notify(relationship)
    create! :notified => relationship.followed,
            :notifier => relationship.follower,
            :title    => I18n.t('notifications.following',
                                :follower => relationship.follower.name)
  end
end
