class RelationshipsController < ApplicationController
  respond_to :json
  before_filter :load_user, :only => [:following, :followers]

  def following
    render 'follow', :locals => {:users => @user.following}
  end

  def followers
    render 'follow', :locals => {:users => @user.followers}
  end

  def create
    respond_with current_user.follow(params[:followed_id])
  end

  def destroy
    respond_with current_user.unfollow(params[:id])
  end

  private

  def load_user
    @user = User.find_by_slug(params[:id]) || User.find(params[:id])
  end
end
