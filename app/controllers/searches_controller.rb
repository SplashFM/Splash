class SearchesController < ApplicationController
  PER_PAGE = 10

  def create
    @tracks, @users = search

    render :layout => nil
  end

  def expand
    %w(track user).include?(params[:type]) or
      raise "Forbidden type for `expand': #{params[:type]}"

    tracks, users = search

    render :partial => 'searches/page',
           :locals => page_params(tracks || users, params[:type])
  end

  private

  def search
    opts   = {:page => params[:page], :per_page => PER_PAGE}
    offset = (current_page - 1) * PER_PAGE

    tracks = if %w(global track).include?(params[:type])
              Track.with_text(params[:f]).limit(PER_PAGE).offset(offset).to_a
            end

    users = if %w(global user).include?(params[:type])
              User.with_text(params[:f]).limit(PER_PAGE).offset(offset).to_a
            end

    [tracks, users]
  end

  helper_method :page_params
  def page_params(collection, type)
    {:f          => params[:f],
     :page       => (params[:page] || 1).to_i + 1,
     :type       => type,
     :per_page   => PER_PAGE,
     :collection => collection}
  end

  def current_page
    params[:page].blank? ? 1 : params[:page].to_i
  end
end
