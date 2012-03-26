class HomeController < ApplicationController
  skip_before_filter :require_user

  def index
    if logged_in?
      render text: '', layout: 'home'
    else
      redirect_to new_user_session_path
    end
  end

  def r
    redirect_to :action => :index
  end

  def about
    render :layout => nil
  end

  def privacy
    render :layout => nil
  end

  def terms
    render :layout => nil
  end
end
