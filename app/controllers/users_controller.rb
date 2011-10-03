class UsersController < ApplicationController
  inherit_resources
  respond_to :html, :json

  skip_before_filter :require_user, :only => 'exists'

  def show
    @events = Event.for(current_user)
    @user = params[:id].blank? ? current_user : User.find_by_slug(params[:id])
  end

  def avatar
    render 'avatar', :layout => false
  end

  def crop
    current_user.fetch_avatar

    respond_with(current_user)
  end

  def exists
    if User.exists?(params.slice(:email))
      head(:ok)
    else
      head(:not_found)
    end
  end

  def update
    params[:user].delete(:password) if params[:user][:password].blank?
    params[:user].delete(:password_confirmation) if params[:user][:password_confirmation].blank?

    @user = current_user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        sign_in(@user, :bypass => true) if current_user.errors.empty?
        format.html { redirect_to home_path }
        format.json { render :json => @user.to_json(:methods => 'avatar_url') }
        format.js { render :json => @user.to_json(:methods => 'avatar_url') }
      else
        format.html { render :action => 'edit' }
      end
    end
  end
end
