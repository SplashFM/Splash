class AccessRequestsController < ApplicationController
  respond_to :json

  skip_before_filter :require_user, :only => [:create, :verify]

  def approve
    if params[:code] == AccessRequest::ADMIN_KEY
      AccessRequest.find(params[:id]).invite
    end

    render :text => 'User invited.'
  end

  def create
    if current_user
      respond_with AccessRequest.
        create(params[:user].merge!(:inviter => current_user))

    else
      respond_with AccessRequest.create(params[:user]),
                   :url_builder => lambda { |code| r_url(code) }
    end
  end

  def verify
    if AccessRequest.code?(params[:code])
      head :ok
    else
      head :not_found
    end
  end
end
