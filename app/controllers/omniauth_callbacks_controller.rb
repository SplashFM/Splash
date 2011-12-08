class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :require_user

  def facebook
    current_user ? link_site('Facebook') : oauthorize("Facebook")
  end

  def twitter
    current_user ? link_site('Twitter') : oauthorize("Twitter")
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private
  def oauthorize(kind)
    @user = User.find_for_oauth(env['omniauth.auth'])

    if @user.persisted?
      @user.fetch_avatar
      @user.update_social_network_link env['omniauth.auth']

      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind
      sign_in_and_redirect @user, :event => :authentication
    else
      redirect_to new_user_session_path and return

      session["devise.provider_data"] = env["omniauth.auth"].except('extra')
      flash[:notice] = I18n.t('devise.registrations.twitter') if @user.initial_provider == 'twitter'
      redirect_to new_user_registration_url
    end
  end

  def link_site(site)
    if current_user.build_social_network_link(env['omniauth.auth']).save
      redirect_to root_path, :notice => I18n.t('devise.omniauth.site_link', :site => site)
    else
      redirect_to root_path, :error => I18n.t('errors.messages.already_taken')
    end
  end
end
