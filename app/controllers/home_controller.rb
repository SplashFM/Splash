class HomeController < ApplicationController
  skip_before_filter :require_user

  def index
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
