class UndiscoveredTracksController < ApplicationController
  respond_to :html, :only => :show
  respond_to :json

  before_filter :require_superuser, only: %w(show destroy)

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
    UndiscoveredTrack.find(params[:id]).destroy if current_user.superuser?

    render :text => 'Track deleted.'
  end

  def download
    redirect_to current_track.data.url
  end

  def flag
    @track = UndiscoveredTrack.find(params[:id])

    AdminMailer.delay.flag(@track, current_user)

    render :json => @track
  end

  def show
    respond_with @track = UndiscoveredTrack.find(params[:id])
  end

  def update
    track = current_user.uploaded_tracks.find(params[:id])

    if track.update_attributes(params.slice(:albums, :title, :performers))
      splash_and_post params, track

      respond_with track
    elsif track.taken?
      begin
        c = track.replace_with_canonical

        splash_and_post params, c

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
