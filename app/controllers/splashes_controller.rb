class SplashesController < ApplicationController
  respond_to :json

  def create
    splash = splash_and_post(params.slice(:track_id, :comment),
                             Track.find(params[:track_id]), params[:parent_id])

    respond_with splash
  end

  def index
    if params[:splashed].present? && params[:tree_with].present?
      respond_with Splash.
        for_tracks(params[:splashed]).
        for_users([params[:tree_with]] <<
            Relationship.followed_ids(params[:tree_with])).
        by_date.
        with_users
    else
      head :bad_request
    end
  end

  def show
    respond_with Splash.find(params[:id]), :full => params[:summary].blank?
  end

  def share
    splash = Splash.find(params[:id])

    if params[:site] == 'twitter'
      twitter_post(splash)
    else
      facebook_post(splash)
    end

    render :json => splash
  end

  protected

  def current_splash
    @splash ||= Splash.find(params[:id])
  end
end
