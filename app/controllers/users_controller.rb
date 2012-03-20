class UsersController < ApplicationController
  TOP_SPLASHERS_PER_PAGE = 10
  PER_SEARCH             = 3
  USER_TAB               = 2
  SIDEBAR_THUMB_COUNT    = 10

  inherit_resources
  respond_to :html, :json

  before_filter      :load_user, :only => [:show]

  has_scope :with_text
  has_scope :filter

  def index
    users =
      if params[:top] == 'true'
        if params[:following].present?
          current_user.top_splashers(current_page, TOP_SPLASHERS_PER_PAGE)
        else
          User.top_splashers(current_page, TOP_SPLASHERS_PER_PAGE)
        end
      else
        results = apply_scopes(User).page(current_page).per(PER_SEARCH)

        if params[:following].present?
          results.followed_by(current_user)
        else
          results
        end
      end

    render :json => Relationship.relate_to_follower(users, current_user)
  end

  def avatar
    render 'avatar', :layout => false
  end

  def crop
    respond_with(current_user)
  end

  def invite
    User.find(params[:id]).invite(params[:code])

    render :text => 'User invited'
  end

  def show
    @following = @user.following.take(SIDEBAR_THUMB_COUNT)
    @followers = @user.followers.take(SIDEBAR_THUMB_COUNT)

    with_relationship =
      if @user == current_user
        @user
      else
        Relationship.relate_to_follower([@user], current_user).first
      end

    respond_with with_relationship do |f|
      f.html { render :layout => 'home' }
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
        format.json { render :json => @user.to_json(:methods => :avatar_geometry) }
        format.js { head :ok }
      else
        format.html { render :action => 'edit' }
        format.js { render :json => @user.errors.to_json, :status => 500 }
        format.json { render :json => @user.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end

  def top
    @selected_tab = USER_TAB

    render :template => 'splashboards/index'
  end
  def invite_friends
    render :template => 'users/invite_friends'
  end
  def merge
    connection = SocialConnection.find_by_provider_and_uid(session["devise.provider"],
                                                           session["devise.uid"])

    if connection
      current_user.merge_account(connection.user)

      flash[:notice] = I18n.t("devise.omniauth.site_link",
                              :site => connection.provider)
    else
      flash[:error] = I18n.t('errors.messages.site_not_linked',
                              :site => connection.provider)
    end

    redirect_to root_path
  end

  private

  def load_user
    @user = if params[:id].blank?
              current_user
            else
              User.find_by_slug(params[:id]) || User.find(params[:id])
            end
  end

  helper_method :own_profile?
  def own_profile?
    @user == current_user
  end
end
