class SplashesController < ApplicationController
  def create
    Splash.create!(:track => Track.find(params[:track_id]),
                   :user => current_user)

    head :created
  rescue ActiveRecord::RecordInvalid
    head :forbidden
  end

  def show
    render :partial => current_splash, :locals => {:expand => true}
  end

  protected

  def current_splash
    @splash ||= Splash.find(params[:id])
  end
end
