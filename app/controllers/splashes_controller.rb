class SplashesController < ApplicationController
  respond_to :json

  def create
    splash = splash_and_post(params.slice(:track_id, :comment),
                             Track.find(params[:track_id]), params[:parent_id])

    respond_with splash
  end

  def show
    opts = {:full => params[:summary].blank?, :user_id => current_user.id}

    respond_with Splash.find(params[:id]).as_json(opts)
  end

  def share
    splash = Splash.find(params[:id])

    if params[:site] == 'twitter'
      twitter_post(splash)
    else
      facebook_post(splash)
    end

    head :ok
  end

  protected

  def current_splash
    @splash ||= Splash.find(params[:id])
  end
end
