class ApplicationController < ActionController::Base
  layout :pick_default_layout

  protect_from_forgery
  before_filter :require_user

  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  protected

  def pjax_request?
    env['HTTP_X_PJAX'].present?
  end

  def render_404
    redirect_to home_url
  end

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

  def splash_and_post(attrs, track, parent=nil)
    Splash.create!(:track     => track,
                   :user      => current_user,
                   :comment   => attrs[:comment],
                   :parent_id => parent).tap { |splash|

      [:facebook, :twitter].each { |network|
        share = attrs[:share] || {}

        if share[network].present? &&
           (n = current_user.social_connection(network))

          n.delay.splashed(splash, self)
        end
      }
    }
  end

  def truncate(text, length = 136, end_string = '...')
    text[0..(length-1)] + end_string
  end

  def logging_out?
    params[:action] == 'destroy' && params[:controller] == 'devise/sessions'
  end

  def require_user
    unless signed_in?(:user) || params[:controller].include?('devise')
      deny_access("Please login or create an account to access that feature.")
    end
  end

  def require_superuser
    deny_access("Please login as a superuser to access that feature.") unless signed_in_as_superuser?
  end

  # override devise method
  def after_sign_in_path_for(resource_or_scope)
    home_url
  end

  def deny_access(message = "You're not allowed to use that page.")
    respond_to { |f|
      f.html {
        flash[:error] = message
        redirect_to home_url, :status => 403
      }
      f.json { head 401 }
    }
  end

  helper_method :active_scaffold?
  def active_scaffold?
    !! active_scaffold_config
  end

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

  helper_method :current_page
  def current_page
    page = params[:page].to_i

    page <= 1 ? 1 : page
  end

  helper_method :next_page
  def next_page(limit=1000)
    (current_page + 1) % (limit + 1)
  end

  def preview?
    AppConfig.preview_host && request.host =~ /#{AppConfig.preview_host}$/
  end

  helper_method :executed
  def executed(name)
    current_user.update_setting "executed_#{name}", true
  end

  helper_method :executed?
  def executed?(name)
    current_user.setting("executed_#{name}").present?
  end

  def pick_default_layout
    if controller_name == 'registrations' && action_name == 'edit'
      nil
    else
      'application'
    end
  end
end
