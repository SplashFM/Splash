class TracksController < ApplicationController
  TRACKS_PER_PAGE = 20

  def top
    @tracks = Track.top_splashed(current_page, TRACKS_PER_PAGE)

    render :layout => !request.xhr?
  end
end
