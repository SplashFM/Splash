class TracksController < ApplicationController
  TRACKS_PER_PAGE = 10
  TRACK_TAB       = 1

  respond_to :json

  has_scope :with_text
  has_scope :popular

  def index
    if params[:user_id] && user = User.find(params[:user_id])
      results = user.top_tracks(current_page, TRACKS_PER_PAGE)
    elsif params[:top]
      results = Track.top_splashed(current_page, TRACKS_PER_PAGE)
    else
      results = apply_scopes(Track).page(current_page)
    end

    respond_with results.map { |t|
      t.active_model_serializer.new(t, current_user, :scoped_score => !! user)
    }
  end

  def top
    @selected_tab = TRACK_TAB

    render :template => 'splashboards/index'
  end

  def flag
    @track = Track.find(params[:track_id])
    AdminMailer.delay.flag(@track, current_user)

    render :json => @track
  end
end
