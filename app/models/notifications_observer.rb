class NotificationsObserver < ActiveRecord::Observer
  observe :relationship, :splash

  def after_create(target)
    send "notify_#{target.class.name.underscore}", target
  end

  private

  def notify_relationship(relationship)
    Following.notify relationship
  end

  def notify_splash(splash)
    Mention.notify splash
  end
end
