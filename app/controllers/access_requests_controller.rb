class AccessRequestsController < ApplicationController
  skip_before_filter :require_user, :only => :create

  def create
    ar = AccessRequest.new(params[:user])

    if ar.save
      render :json => ar, :status => :created
    else
      render :json => ar
    end
  end
end
