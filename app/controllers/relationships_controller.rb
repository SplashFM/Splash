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
    attrs = params.slice(:follower_id, :followed_id)

    respond_with current_user.relationships.create!(attrs)
  end

  def destroy
    respond_with current_user.relationships.find(params[:id]).destroy
  end

  private

  def load_user
    @user = User.find_by_slug(params[:id]) || User.find(params[:id])
  end
end
