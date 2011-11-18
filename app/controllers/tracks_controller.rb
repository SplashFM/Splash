class TracksController < ApplicationController
  TRACKS_PER_PAGE         = 10

  respond_to :json

  has_scope :with_text

  def index
    sth = current_user.try(:splashed_tracks_hash)
    if params[:user_id] && user = User.find(params[:user_id])
      results = user.top_tracks(current_page, TRACKS_PER_PAGE)
    elsif params[:top]
      results = Track.top_splashed(current_page, TRACKS_PER_PAGE)
    else
      results = apply_scopes(Track).page(current_page)
    end

    respond_with results.as_json(:splashed_tracks => sth)
  end

  def top
    render :template => 'splashboards/index'
  end
end
