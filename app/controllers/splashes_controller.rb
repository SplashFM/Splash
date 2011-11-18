class SplashesController < ApplicationController
  respond_to :json

  def create
    splash = splash_and_post(params.slice(:track_id, :comment),
                             Track.find(params[:track_id]), params[:parent_id])

    respond_with splash
  end

  def show
    respond_with Splash.find(params[:id]).
      as_json(:full => true, :user_id => current_user.id)
  end

  def tweet
    splash = Splash.find(params[:id])
    twitter_post(splash)

    head :ok
  end

  protected

  def current_splash
    @splash ||= Splash.find(params[:id])
  end
end
