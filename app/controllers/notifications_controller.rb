class NotificationsController < ApplicationController
  def reset_read
    Notification.mark_as_read(current_user)

    head :ok
  end

  def index
    render :partial => 'shared/notification', :collection => Notification.for(current_user)
  end
end
