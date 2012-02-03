class Following < Notification
  def self.notify(relationship)
    create! :notified => relationship.followed,
            :notifier => relationship.follower
  end
end
