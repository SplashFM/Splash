class RelationshipsController < ApplicationController
  respond_to :js

  def following
    @following = current_user.following
    render 'follow', :locals => {:users => @following}
  end

  def followers
    @followers = current_user.followers
    render 'follow', :locals => {:users => @followers}
  end

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
