class HomeController < ApplicationController
  skip_before_filter :require_user, :only => [:index, :r, :privacy, :terms]

  def index
    if logged_in?
      render
    else
      sign_out :user
      redirect_to new_user_session_path
    end
  end

  def r
    redirect_to :action => :index
  end

  def splashboards
    render :template => 'splashboards/index'
  end

  def privacy
  end

  def terms
  end
end
