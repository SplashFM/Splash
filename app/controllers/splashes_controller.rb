class SplashesController < ApplicationController
  respond_to :json

  def create
    splash_and_post(params[:splash], Track.find(params[:track_id]), params[:parent_id])

    head :created
  rescue ActiveRecord::RecordInvalid
    head :forbidden
  end

  def show
    respond_with Splash.find(params[:id]).as_full_json
  end

  protected

  def current_splash
    @splash ||= Splash.find(params[:id])
  end
end
