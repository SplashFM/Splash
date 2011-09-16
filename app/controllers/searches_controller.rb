class SearchesController < ApplicationController
  PER_PAGE = 10

  def create
    @tracks, @users = search

    render :layout => nil
  end

  def expand
    tracks, _ = search

    render :partial => 'searches/page', :locals => page_params(tracks)
  end

  private

  def search
    opts = {:page => params[:page], :per_page => PER_PAGE}

    [Track.filtered(params[:f]).paginate(opts),
     params[:type] == 'global' ? User.filtered(params[:f]) : []]
  end

  helper_method :page_params
  def page_params(collection)
    {:f          => params[:f],
     :page       => (params[:page] || 1).to_i + 1,
     :type       => params[:type],
     :collection => collection}
  end
end
