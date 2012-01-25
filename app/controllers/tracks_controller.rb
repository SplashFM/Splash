class TracksController < ApplicationController
  TRACKS_PER_SEARCH_PAGE      = 5
  TRACKS_PER_ALL_RESULTS_PAGE = 50
  TRACKS_PER_PAGE             = 10
  TRACK_TAB                   = 1

  respond_to :json

  def index
    if params[:user_id] && user = User.find(params[:user_id])
      results = user.top_tracks(current_page, TRACKS_PER_PAGE)
    elsif params[:top]
      results = Track.top_splashed(current_page, TRACKS_PER_PAGE)
    else
      per = if params[:popular].present?
              TRACKS_PER_SEARCH_PAGE
            else
              TRACKS_PER_ALL_RESULTS_PAGE
            end

      results = Track.
        with_text(params[:with_text], params[:popular].present?).
        page(current_page).
        per(per)
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
