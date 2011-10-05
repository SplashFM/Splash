class TracksController < ApplicationController
  def create
    track, splash = UndiscoveredTrack.
      create_and_splash(params[:track],
                        current_user,
                        params[:splash][:comment])

    if splash
      head :created
    else
      head :unprocessable_entity
    end
  end

  def download
    custom_send_file current_track.download_path
  end

  protected

  def current_track
    @track ||= Track.find(params[:id])
  end
end
