class NotificationsObserver < ActiveRecord::Observer
  observe :relationship, :comment

  def after_create(target)
    send "notify_#{target.class.name.underscore}", target
  end

  private

  def notify_relationship(relationship)
    Following.notify relationship
  end

  def notify_comment(comment)
    Mention.notify comment
  end
end
