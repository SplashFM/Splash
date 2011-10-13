require 'event_generator'

class UsersController < ApplicationController
  include EventGenerator

  inherit_resources
  respond_to :html, :json

  skip_before_filter :require_user, :only => 'exists'
  skip_before_filter :require_name, :only => ['edit', 'update']
  before_filter      :load_user, :only => [:show, :events, :event_updates]

  def show
    @events = profile_events
  end

  def avatar
    render 'avatar', :layout => false
  end

  def crop
    current_user.fetch_avatar

    respond_with(current_user)
  end

  def events
    refresh_events profile_events, @user
  end

  def event_updates
    render_event_updates profile_events.count
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

  private

  def load_user
    @user = params[:id].blank? ? current_user : User.find_by_slug!(params[:id])
  end

  def profile_events
    Event.for(@user, params[:last_update], params[:filters])
  end
end
