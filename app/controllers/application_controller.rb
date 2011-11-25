class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_user

  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  layout Proc.new { |c| pjax_request? ? 'pjax' : request.xhr? ? false : 'application'}

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
    splash = Splash.create!(:track => track,
                            :user => current_user,
                            :comment => attrs[:comment],
                            :parent_id => parent)
    facebook_post(splash) if attrs[:facebook_post] == '1'
    twitter_post(splash) if attrs[:twitter_post] == '1'
    splash
  end

  def facebook_post(splash)
    if current_user.has_social_connection? 'facebook'
      host = Rails.env.development? ? 'splash.test' : AppConfig.preferred_host

      fb_user = FbGraph::User.me(current_user.social_connection('facebook').token)
      link = fb_user.link!(:link => splash_url(splash, :host => host),
                          :message => "#{splash.user.name} splashed #{splash.track.title}. #{splash.comments.first.body}")
    end
  end

  def twitter_post(splash)
    if current_user.has_social_connection? 'twitter'
      twitter = current_user.social_connection('twitter')
      Twitter.configure do |config|
        config.oauth_token = twitter.token
        config.oauth_token_secret = twitter.token_secret
      end

      begin
        Twitter.update(truncate([splashboards_url,
                                  splash.user.name,
                                  'splashed',
                                  splash.track.title,
                                  splash.comments.first.body].join(' ')))
      rescue Twitter::NotFound, Twitter::Forbidden => e
        notify_hoptoad(e)
      end
    end
  end

  def truncate(text, length = 136, end_string = '...')
    text[0..(length-1)] + end_string
  end

  def logging_out?
    params[:action] == 'destroy' && params[:controller] == 'devise/sessions'
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


  before_filter :check_http_auth, :unless => :preview?
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
end
