class UndiscoveredTracksController < ApplicationController
  respond_to :json

  def create
    respond_with current_user.uploaded_tracks.build(params.slice(:data))
  end

  def destroy
    current_user.uploaded_tracks.find(params[:id]).destroy

    render_upload_form :upload
  end

  def download
    custom_send_file current_track.download_path
  end

  def update
    track      = current_user.uploaded_tracks.find(params[:id])
    splashable = if track.update_attributes(params.slice(:title, :performers))
                   track
                 elsif track.taken?
                   track.replace_with_canonical
                 else
                   nil
                 end

    if splashable
      begin
        splash_and_post(params.slice(:comment), splashable)
      rescue ActiveRecord::RecordInvalid
        # do nothing
      end
    end

    respond_with track
  end

  protected

  def current_track
    @track ||= Track.find(params[:id])
  end
end
