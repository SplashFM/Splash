class RelationshipsController < ApplicationController
  respond_to :json
  before_filter :load_user, :only => [:following, :followers]

  def following
    @following = @user.following

    respond_to { |f|
      f.html { render 'follow', :locals => {:users => @following} }
      f.js   { render 'follow', :locals => {:users => @following} }
      f.json { render :json => @following.to_json(:includes => [:id, :name]) }
    }
  end

  def followers
    @followers = @user.followers
    render 'follow', :locals => {:users => @followers}
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
