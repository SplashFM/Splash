class SuggestedSplashersController < ApplicationController
  def index
    render :partial => "users/suggested_splasher", :collection => current_user.suggested_users, :as => :user
  end

 def destroy
    user = User.find(params[:id])
    current_user.ignore_suggested(user)

    render :partial => "users/suggested_splasher", :collection => current_user.suggested_users, :as => :user
  end
end
