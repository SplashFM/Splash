class SuggestedSplashersController < ApplicationController
  respond_to :json

  def index
    respond_with current_user.recommended_users.page(1).per(100)
  end

  def destroy
    current_user.ignore_suggested(params[:id])

    respond_with true
  end
end
