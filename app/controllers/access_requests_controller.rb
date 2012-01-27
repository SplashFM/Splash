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
      attrs  = params[:user].merge!(:inviter => current_user)
      ar     = AccessRequest.new(attrs)

      if ar.save
        social = {:uid   => params[:user][:uid],
                  :url   => new_user_registration_url(:code => ar.code)}

        render :json => ar.as_json.merge!(:social => social)
      else
        render :json => ar.errors,
               :status => :unprocessable_entity
      end
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
