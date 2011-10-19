class SplashesController < ApplicationController
  def create
    splash_and_post(params[:splash], Track.find(params[:track_id]), params[:parent_id])

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
