class SuggestedSplashersController < ApplicationController
  respond_to :json

  def destroy
    current_user.ignore_suggested(params[:id])

    respond_with true
  end
end
