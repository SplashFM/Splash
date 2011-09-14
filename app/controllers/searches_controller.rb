class SearchesController < ApplicationController
  def create
    @tracks = Track.filtered(params[:f])

    render :layout => nil
  end
end
