class SplashesController < ApplicationController
  respond_to :json

  def create
    splash = splash_and_post(params.slice(:track_id, :comment),
                             Track.find(params[:track_id]), params[:parent_id])

    respond_with splash
  end

  def index
    if params[:splashed].present? && params[:tree_with].present?
      respond_with Splash.
        for_tracks(params[:splashed]).
        for_users([params[:tree_with]] <<
            Relationship.followed_ids(params[:tree_with])).
        by_date.
        with_users
    else
      head :bad_request
    end
  end

  def show
    respond_with Splash.find(params[:id]), :full => params[:summary].blank?
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
end
