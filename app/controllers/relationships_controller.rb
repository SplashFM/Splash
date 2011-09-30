class RelationshipsController < ApplicationController
  respond_to :js

  def create
    @user = User.find_by_slug(params[:id])
    relationship = current_user.follow @user
    respond_with relationship
  end

  def destroy
    @user = User.find_by_slug(params[:id])
    relationship = current_user.unfollow @user
    respond_with relationship
  end
end
