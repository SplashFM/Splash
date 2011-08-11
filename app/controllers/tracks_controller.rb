class TracksController < ApplicationController
  def index
    if params[:f].present?
      @results = Track.search(params[:f])
    end
  end
end
