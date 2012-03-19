class UndiscoveredTracksController < ApplicationController
  respond_to :json

  skip_before_filter :require_user, :only => :download

  def create
    track = current_user.uploaded_tracks.create(params.slice(:local_data))

    if track.taken?
      canonical = track.replace_with_canonical

      if ! Splash.for?(current_user, canonical)
        respond_with_canonical canonical
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
    track = current_user.uploaded_tracks.find(params[:id])

    if track.update_attributes(params.slice(:albums, :title, :performers))
      splash_and_post params.slice(:comment), track

      respond_with track
    elsif track.taken?
      begin
        c = track.replace_with_canonical

        splash_and_post params.slice(:comment), c

        respond_with_canonical c
      rescue ActiveRecord::RecordInvalid => e
        respond_with e.record, :status => :forbidden
      end
    else
      respond_with track
    end
  end

  protected

  def current_track
    @track ||= Track.find(params[:id])
  end

  def respond_with_canonical(canonical)
    respond_with canonical, :status => :ok do |want|
      want.json { render :json => canonical }
    end
  end
end
