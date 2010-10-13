class Admin::UsersController < ApplicationController

  filter_access_to :all
  before_filter :custom_flash_display

  active_scaffold :users do |config|
    actions.exclude :show
    base_cols = [:email, :avatar, :superuser]
    config.list.columns = base_cols + [:confirmed?, :created_at]
    config.create.columns = base_cols + [:password, :password_confirmation, :confirmed_at]
    config.update.columns = base_cols + [:confirmed_at]
    columns[:superuser].label = 'Super User'
    columns[:superuser].form_ui = :checkbox
    columns[:superuser].inplace_edit = true
    config.search.columns = [:email]

    config.action_links.add 'impersonate', :label => 'Impersonate',
      :page => true, :type => :member, :method => :post
  end

  def impersonate
    user = User.find params[:id]
    unless user.confirmed?
      flash[:error] = "#{user.email} can't be impersonated, because he hasn't confirmed his email address, and therefore can't log in."
      redirect_to :action => :index
      return
    end
    sign_in_and_redirect(:user, user)
    session[:impersonated_by] = current_user.id
    flash[:notice] = "You are now impersonating #{user.email}."
  end

  def deimpersonate
    unless session[:impersonated_by]
      flash[:error] = "Unfortunately, you are the real you, and not an impersonation of you."
      redirect_to after_sign_in_path_for(:user)
      return
    end

    user = User.find session[:impersonated_by]
    sign_in(:user, user)
    session[:impersonated_by] = nil

    flash[:info] = "Welcome back to you, #{user.email}."
    redirect_to :action => :index
  end

end
