class HomeController < ApplicationController
  skip_before_filter :require_user, :only => :index

  def index
    if logged_in?
      render
    else
      redirect_to 'http://signup.splash.fm'
    end
  end

  def splashboards
    render :template => 'splashboards/index'
  end
end
