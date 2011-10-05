class HomeController < ApplicationController
  include RenderHelper

  skip_before_filter :require_user

  def index
    if logged_in?
      @events = dashboard_events

      render
    else
      redirect_to new_user_session_path
    end
  end

  def events
    render_events(dashboard_events)
  end

  private

  def dashboard_events
    Event.for(current_user.following + [current_user], params[:filters])
  end
end
