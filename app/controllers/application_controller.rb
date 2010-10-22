class ApplicationController < ActionController::Base
  protect_from_forgery

  def custom_flash_display
    @custom_flash_display = true
  end

  helper_method :signed_in_as_superuser?
  def signed_in_as_superuser?
    signed_in?(:user) && current_user.superuser?
  end

  helper_method :logged_in?
  def logged_in?
    user_signed_in?
  end

  def require_user
    deny_access("Please login or create an account to access that feature.") unless signed_in?(:user)
  end

  def require_superuser
    deny_access("Please login as a superuser to access that feature.") unless signed_in_as_superuser?
  end

  # override devise method
  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(User) && resource_or_scope.superuser?
      admin_users_url
    else
      home_url
    end
  end

  def deny_access(message = "You're not allowed to use that page.")
    flash[:error] = message
    redirect_to home_url
  end

  helper_method :active_scaffold?
  def active_scaffold?
    !! active_scaffold_config
  end
end
