class TracksController < ApplicationController
  def create
    UndiscoveredTrack.create!(params[:track])

    head :ok
  end

  def download
    custom_send_file current_track.download_path
  end

  protected

  def current_track
    @track ||= Track.find(params[:id])
  end
end
