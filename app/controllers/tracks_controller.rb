class TracksController < ApplicationController
  MAX_RESULTS = 3

  def index
    if params[:f].present?
      @results = soundcloud.search(params[:f], :limit => MAX_RESULTS)
    end
  end
end
