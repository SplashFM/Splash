class RelationshipsController < ApplicationController
  respond_to :js
  before_filter :load_user

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
    relationship = current_user.follow @user
    respond_with relationship
  end

  def destroy
    relationship = current_user.unfollow @user
    respond_with relationship
  end

  private

  def load_user
    @user = User.find_by_slug(params[:id]) || User.find(params[:id])
  end
end
