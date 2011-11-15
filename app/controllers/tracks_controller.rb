class TracksController < ApplicationController
  TRACKS_PER_PAGE         = 10

  respond_to :json

  has_scope :with_text

  def index
    if params[:top]
      results = Track.top_splashed(current_page, TRACKS_PER_PAGE)
    else
      results = apply_scopes(Track).page(current_page)
    end
    respond_with results
  end

  def top
    @tracks = Track.top_splashed(current_page, TRACKS_PER_PAGE)
  end
end
