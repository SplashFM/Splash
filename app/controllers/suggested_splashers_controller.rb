class SuggestedSplashersController < ApplicationController
  def index
    render :partial => "shared/suggested_splashers"
  end

 def destroy
    user = User.find_by_slug(params[:id])
    current_user.ignore_suggested(user)

    render :partial => "users/suggested_splasher", :collection => current_user.recommended_users, :as => :user
  end
end
