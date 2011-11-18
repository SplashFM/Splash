class UndiscoveredTracksController < ApplicationController
  respond_to :json

  def create
    track = current_user.uploaded_tracks.build(params.slice(:data))

    if track.save
      respond_with track
    elsif track.taken?
      canonical = track.replace_with_canonical

      if ! Splash.for?(current_user, canonical)
        respond_with canonical, :status => :ok
      else
        head :forbidden
      end
    else
      respond_with track
    end
  end

  def destroy
    current_user.uploaded_tracks.find(params[:id]).destroy

    render_upload_form :upload
  end

  def download
    redirect_to current_track.data.url
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
      rescue ActiveRecord::RecordInvalid => e
        respond_with e.record, :status => :forbidden
      end
    end

    respond_with track
  end

  protected

  def current_track
    @track ||= Track.find(params[:id])
  end
end
