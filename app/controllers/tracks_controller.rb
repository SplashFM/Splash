class TracksController < ApplicationController
  def index
    if params[:f].present?
      tracks = Track.filtered(params[:f])

      render :partial => 'index', :locals => {:tracks => tracks}
    end
  end
end
