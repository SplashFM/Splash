class TracksController < ApplicationController
  def create
    Track.create!(params[:track])

    head :ok
  end

  def download
    custom_send_file current_track.download_path
  end

  def show
    render :partial => 'track_info',
           :object  => current_track,
           :as      => :track
  end

  protected

  def current_track
    @track ||= Track.find(params[:id])
  end
end
