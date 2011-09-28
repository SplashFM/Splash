class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_user

  protected

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
    deny_access("Please login or create an account to access that feature.") unless signed_in?(:user) || params[:controller].include?('devise')
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
    redirect_to home_url, :status => 403
  end

  helper_method :active_scaffold?
  def active_scaffold?
    !! active_scaffold_config
  end


  before_filter :check_http_auth
  def check_http_auth
    auth = AppConfig.http_auth
    if auth && ! Rails.env.test?
      authenticate_or_request_with_http_basic do |username, password|
        username == auth['username'] && password == auth['password']
      end
      # tell Devise/warden that it's OK, we'll take it from here if
      # the user isn't authorized via simple auth.
      warden.custom_failure! if performed?
    else
      true
    end
  end

  before_filter :check_protocol
  def check_protocol
    if AppConfig.ssl_required && !request.ssl?
      redirect_to request.url.sub("http://", "https://")
    end
  end

  before_filter :check_host
  def check_host
    host_wanted = AppConfig.preferred_host
    if host_wanted.present? && request.host != host_wanted
      redirect_to request.url.sub(request.host, host_wanted)
    end
  end

  def custom_send_file(*args)
    send_file *args
  end

  # Mark layout elements as hidden. Usage:
  #  hide :navigation, :auth_controls
  def self.hide(*elements)
    before_filter do |c|
      hidden = c.instance_variable_get(:'@hidden_elements') || Array.new
      c.instance_variable_set(:'@hidden_elements', hidden | elements)
    end
  end

  def hidden?(element)
    @hidden_elements && @hidden_elements.include?(element)
  end

  helper_method :hidden?
end
