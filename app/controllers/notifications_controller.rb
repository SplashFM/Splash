class NotificationsController < ApplicationController
  respond_to :json

  def reset_read
    Notification.mark_as_read(current_user)

    head :ok
  end

  def index
    respond_with Notification.for(current_user)
  end
end
