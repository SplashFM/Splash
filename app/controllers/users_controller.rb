class UsersController < ApplicationController
  inherit_resources
  respond_to :html

  skip_before_filter :require_user, :only => 'exists'

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

    update! do |success, failure|
      success.html { redirect_to home_path}
      failure.html { render :action => 'edit'}
    end
  end
end
