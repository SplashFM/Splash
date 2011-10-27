class NotificationsObserver < ActiveRecord::Observer
  observe :relationship

  def after_create(target)
    send "notify_#{target.class.name.underscore}", target
  end

  private

  def notify_relationship(relationship)
    Notification.create(:notified => relationship.followed,
                        :notifier => relationship.follower,
                        :title => I18n.t(:following, :scope => 'emails.subjects', :follower => relationship.follower.name))
  end
end
