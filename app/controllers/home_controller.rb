require 'event_generator'

class HomeController < ApplicationController
  include EventGenerator

  skip_before_filter :require_user

  def index
    if logged_in?
      is_owner

      @events = dashboard_events(true)

      render
    else
      redirect_to new_user_session_path
    end
  end

  def events
    refresh_events dashboard_events(true)
  end

  def event_updates
    render_event_updates dashboard_events(false).count
  end

  private

  def dashboard_events(include_self)
    users = current_user.following + (include_self ? [current_user] : [])

    Event.for(users, params[:last_update], params[:filters])
  end
end
