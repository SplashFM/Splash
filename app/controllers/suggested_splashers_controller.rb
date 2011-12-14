class SuggestedSplashersController < ApplicationController
  before_filter :load_user, :only => :destroy

  def index
    render :partial => "shared/suggested_splashers"
  end

 def destroy
    current_user.ignore_suggested(@user.id)

    render :partial => "users/suggested_splasher", :collection => current_user.recommended_users, :as => :user
  end

private

  def load_user
    @user = User.find_by_slug(params[:id]) || User.find(params[:id])
  end
end
