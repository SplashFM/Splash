class HomeController < ApplicationController
  skip_before_filter :require_user, :only => :index

  def index
    if preview?
      render 'preview', :layout => false
    elsif ! logged_in?
      redirect_to new_user_session_path unless logged_in?
    else
      render
    end
  end
end
