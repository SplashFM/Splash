class UndiscoveredTracksController < ApplicationController
  def create
    track = UndiscoveredTrack.new(params[:undiscovered_track])

    if track.save
      render :partial => 'tracks/upload',
             :locals  => {:track => track, :splash => Splash.new(params[:splash])}
    else
      head :unprocessable_entity
    end
  end

  def download
    custom_send_file current_track.download_path
  end

  def update
    track = UndiscoveredTrack.find(params[:id])

    splashable = if track.update_attributes(params[:undiscovered_track])
                   track
                 elsif track.taken?
                   track.replace_with_canonical
                 else
                   nil
                 end

    if splashable
      Splash.create!(:track   => splashable,
                     :user    => current_user,
                     :comment => params[:splash][:comment])

      head :ok
    else
      head :unprocessable_entity
    end
  end

  protected

  def current_track
    @track ||= Track.find(params[:id])
  end
end
