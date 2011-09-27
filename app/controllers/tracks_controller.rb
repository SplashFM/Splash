class TracksController < ApplicationController
  def create
    Track.create!(params[:track])

    head :ok
  end

  def show
    render :partial => 'track_info'
  end
end
