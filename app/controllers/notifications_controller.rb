class NotificationsController < ApplicationController
  respond_to :json

  def reset_read
    Notification.mark_as_read(current_user)

    head :ok
  end

  def index
    n = Notification.for(current_user)

    if params[:count].present?
      render :json => n.unread.count
    else
      if params[:all].present?
        respond_with n.by_recency
      else
        respond_with n.by_recency.page(1)
      end
    end
  end
end
