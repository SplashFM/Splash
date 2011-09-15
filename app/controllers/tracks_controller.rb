class TracksController < ApplicationController
  def create
    Track.create!(params[:track])

    head :ok
  end
end
