class AccessRequestsController < ApplicationController
  respond_to :json

  skip_before_filter :require_user, :only => :create

  def approve
    AccessRequest.find(params[:id]).invite

    render :text => 'User invited.'
  end

  def create
    respond_with AccessRequest.create(params[:user])
  end
end
