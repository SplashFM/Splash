class SuggestedSplashersController < ApplicationController
  def index
    render :partial => "home/suggested_splasher", :collection => current_user.suggested_users, :as => :user
  end
end
