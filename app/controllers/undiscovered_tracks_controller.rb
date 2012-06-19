class UndiscoveredTracksController < ApplicationController
  respond_to :html, :only => :show
  respond_to :json

  before_filter :require_superuser, only: %w(show destroy)

  skip_before_filter :require_user, :only => :download

  def create
    track = current_user.uploaded_tracks.create(params.slice(:local_data))

    if track.taken?
      logger.info("<======create after track is taken ===>")
      canonical = track.replace_with_canonical

      if ! Splash.for?(current_user, canonical)
        logger.info("<======! Splash.for? ===> canonical = #{canonical.inspect}")
        respond_with_canonical canonical
      else
        logger.info("<====== im_used ====>")
        head :im_used
      end
    else
      logger.info("<====== track is not taken ===> #{track.inspect}")
      respond_with track
    end
  end

  def destroy
    UndiscoveredTrack.find(params[:id]).destroy if current_user.superuser?

    render :text => 'Track deleted.'
  end

  def download
    if current_user and !Splash.for?(current_user, current_track)
      Splash.create!(:track     => current_track,
                     :user      => current_user)
    end
    redirect_to current_track.download_url
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
      respond_with(s = splash_and_post(params, track)) { |f|
        f.json { render json: s }
      }
    elsif track.taken?
      begin
        c = track.replace_with_canonical

        respond_with(s = splash_and_post(params, c)) { |f|
          f.json { render json: s }
        }
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
