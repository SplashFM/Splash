class NotificationsObserver < ActiveRecord::Observer
  observe :relationship

  def after_create(target)
    send "notify_#{target.class.name.underscore}", target
  end

  private

  def notify_relationship(relationship)
    Following.notify relationship
  end
end
