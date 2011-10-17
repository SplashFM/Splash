require 'song_file'

class UndiscoveredTracksController < ApplicationController
  include RenderHelper

  def create
    track = UndiscoveredTrack.new(params[:undiscovered_track])

    if track.save
      track.fill_metadata

      render_upload_form :metadata, track
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
      render_upload_form :metadata, track, :unprocessable_entity
    end
  end

  protected

  def current_track
    @track ||= Track.find(params[:id])
  end
end
