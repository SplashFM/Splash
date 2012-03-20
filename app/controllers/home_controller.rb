class HomeController < ApplicationController
  skip_before_filter :require_user

  def index
    render text: '', layout: 'home'
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
