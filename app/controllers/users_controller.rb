class UsersController < ApplicationController
  TOP_SPLASHERS_PER_PAGE = 10
  PER_SEARCH = 10
  USER_TAB = 2

  inherit_resources
  respond_to :html, :json

  skip_before_filter :require_user, :only => 'exists'
  before_filter      :load_user, :only => [:show, :events, :event_updates]

  has_scope :with_text
  has_scope :filter

  def index
    if params[:top] == 'true'
      results = User.top_splashers(current_page, TOP_SPLASHERS_PER_PAGE)
    else
      results = apply_scopes(User)
      results = results.followed_by(current_user) if params[:following].present?
      results.
        page(current_page).per(PER_SEARCH).
        map { |u| u.as_json.merge!(:path => user_slug_path(u)) }
    end
    render :json => results
  end

  def avatar
    render 'avatar', :layout => false
  end

  def crop
    current_user.fetch_avatar

    respond_with(current_user)
  end

  def exists
    if User.exists?(params.slice(:email))
      render :json => true
    else
      render :json => params.slice(:email), :status => 404
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
    @user = params[:id].blank? ? current_user : User.find_by_slug(params[:id])
  end

  helper_method :own_profile?
  def own_profile?
    @user == current_user
  end
end
