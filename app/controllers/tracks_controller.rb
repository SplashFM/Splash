class TracksController < ApplicationController
  TRACKS_PER_SEARCH_PAGE      = 5
  TRACKS_PER_ALL_RESULTS_PAGE = 50
  TRACKS_PER_PAGE             = 10
  TRACK_TAB                   = 1

  respond_to :json

  def index
    following = params[:following].present?
    week      = params[:week].present?

    if params[:top]
      results = if following
                   current_user.top_tracks(week, current_page, TRACKS_PER_PAGE)
                else
                  Track.top_splashed(week, current_page, TRACKS_PER_PAGE)
                end
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
      t.active_model_serializer.new(t,
                                    current_user,
                                    :scoped_score => following || week)
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
