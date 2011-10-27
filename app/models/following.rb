class Following < Notification
  def self.notify(relationship)
    create!(:notified => relationship.followed,
            :notifier => relationship.follower,
            :title    => I18n.t(:following, :scope => 'emails.subjects',
                                :follower => relationship.follower.name))
  end
end
