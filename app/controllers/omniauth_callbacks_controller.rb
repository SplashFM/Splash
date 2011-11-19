class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :require_user

  def facebook
    if current_user
      link_site('Facebook')
    else
      oauthorize("Facebook")
    end
  end

  def twitter
    if current_user
      link_site('Twitter')
    else
      oauthorize("Twitter")
    end
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private
  def oauthorize(kind)
    @user = User.find_for_oauth(env['omniauth.auth'])

    if @user.persisted?
      @user.fetch_avatar
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.provider_data"] = env["omniauth.auth"].except('extra')
      flash[:notice] = I18n.t('devise.registrations.twitter') if @user.initial_provider == 'twitter'
      redirect_to new_user_registration_url
    end
  end

  def link_site(site)
    access_token = env['omniauth.auth']

    provider      = access_token['provider']
    uid           = access_token['uid']
    token         = access_token['credentials']['token']
    token_secret  = access_token['credentials'].try(:[], 'secret')

    current_user.social_connections.create(:provider => provider,
                                          :uid => uid,
                                          :token => token,
                                          :token_secret => token_secret)

    redirect_to root_path, :notice => I18n.t('devise.omniauth.site_link', :site => site)
  end
end
