class HomeController < ApplicationController
  skip_before_filter :require_user, :only => [:index, :privacy, :terms]

  def index
    if logged_in?
      render
    elsif Rails.env.development?
      redirect_to new_user_session_path
    else
      redirect_to 'http://signup.splash.fm'
    end
  end

  def splashboards
    render :template => 'splashboards/index'
  end

  def privacy
  end

  def terms
  end
end
