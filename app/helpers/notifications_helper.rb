module NotificationsHelper
  def notifications
    Notification.for(current_user)
  end

  def new_notifications
    notifications.unread
  end
end
