class HomeController < ApplicationController
  skip_before_filter :require_user

  def index
    if logged_in?
      @events = Event.all

      render
    else
      redirect_to new_user_session_path
    end
  end

end
