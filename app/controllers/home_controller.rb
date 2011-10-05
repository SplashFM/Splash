class HomeController < ApplicationController
  include RenderHelper

  skip_before_filter :require_user

  def index
    if logged_in?
      @events = Event.all

      render
    else
      redirect_to new_user_session_path
    end
  end

  def events
    render_events(Event.all)
  end
end
