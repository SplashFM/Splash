class SearchesController < ApplicationController
  def create
    @tracks = Track.filtered(params[:f])
    @users  = params[:type] == 'global' ? User.filtered(params[:f]) : []

    render :layout => nil
  end
end
