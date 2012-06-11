class SplashesController < ApplicationController
  respond_to :html, :only => :show
  respond_to :json

  skip_before_filter :require_user, :only => :show

  def create
    splash = splash_and_post(params,
                             Track.find(params[:track_id]), params[:parent_id])

    respond_with splash
  end
  
  def unsplash
  	
  	splash = Splash.where(:track_id => params[:id], :user_id => current_user.id).first
  	Comment.delete_all(:splash_id => splash.id)
  	splash.track.decrement_splash_count
  	splash.track.decrement_splash_count_week
  	splash.user.decrement_splash_count
  	current_user.remove_track_from_splashboard(params[:id])
  	splash.delete
  	
  	respond_with splash
  end

  def index
    if params[:splashed].present?
      respond_with Splash.
        for_tracks(params[:splashed]).
        by_date.
        with_users
    else
      head :bad_request
    end
  end

  def show
    full = request.format =~ /html/ || params[:summary].blank?

    @splash = SplashSerializer.new(Splash.find(params[:id]),
                                   current_user,
                                   :full => full)

    respond_with @splash do |f|
      f.html { render :layout => 'home' }
      f.all  { render :layout => 'home' }
    end
  end

  def share
    splash = Splash.find(params[:id])

    if params[:site] == 'twitter'
      twitter_post(splash)
    else
      facebook_post(splash)
    end

    render :json => splash
  end

  protected

  def current_splash
    @splash ||= Splash.find(params[:id])
  end

  def facebook_post(splash)
    if facebook = current_user.social_connection('facebook')
      host = Rails.env.development? ? 'splash.test' : AppConfig.preferred_host

      fb_user = FbGraph::User.me(facebook.token)
      link = fb_user.link!(:link => splash_url(splash, :host => host),
                          :message => "#{splash.user.name} splashed #{splash.track.title}. #{splash.comments.first.body}")
    end
  end

  def twitter_post(splash)
    if twitter = current_user.social_connection('twitter')
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
end
