class TracksController < ApplicationController
  def index
    if params[:f].present?
      @results = Track.filtered(params[:f])
    end
  end
end
