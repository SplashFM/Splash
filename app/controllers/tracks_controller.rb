class TracksController < ApplicationController
  def index
    @results = soundcloud.search(params[:f]) if params[:f].present?
  end
end
