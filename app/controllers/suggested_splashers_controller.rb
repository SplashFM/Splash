class SuggestedSplashersController < ApplicationController
  respond_to :json

  def index
  	suggested_splashers = current_user.recommended_users(100)
		suggested_splashers = current_user.featured_splashers if suggested_splashers.blank? 
    respond_with suggested_splashers
  end

  def destroy
    current_user.ignore_suggested(params[:id])

    respond_with true
  end
end
