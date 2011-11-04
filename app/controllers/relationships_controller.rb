class RelationshipsController < ApplicationController
  respond_to :js

  def following
    @following = current_user.following

    respond_to { |f|
      f.html { render 'follow', :locals => {:users => @following} }
      f.js   { render 'follow', :locals => {:users => @following} }
      f.json { render :json => @following.to_json(:includes => [:id, :name]) }
    }
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
