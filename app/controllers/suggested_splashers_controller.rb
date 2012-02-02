class SuggestedSplashersController < ApplicationController
  respond_to :json

  def index
    respond_with current_user.recommended_users(100)
  end

  def destroy
    current_user.ignore_suggested(params[:id])

    respond_with true
  end
end
