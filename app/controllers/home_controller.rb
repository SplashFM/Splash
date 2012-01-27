class HomeController < ApplicationController
  skip_before_filter :require_user, :only => [:index, :r, :privacy, :terms]

  before_filter :visit_friends, :if => :visit_friends?

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

  private

  def visit_friends
    current_user.update_setting(:visited_friends, true)

    redirect_to friends_path
  end

  def visit_friends?
    logged_in? && ! current_user.setting(:visited_friends)
  end
end
