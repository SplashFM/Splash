class SplashesController < ApplicationController
  def create
    Splash.create!(:track => Track.find(params[:track_id]),
                   :user => current_user)

    head :created
  rescue ActiveRecord::RecordInvalid
    head :forbidden
  end
end
