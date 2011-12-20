class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :require_user

  def facebook
    current_user ? link_site('Facebook') : authorize_facebook
  end

  def twitter
    current_user ? link_site('Twitter') : authorize_twitter
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private

  def authorize_facebook
    user = User.find_for_oauth(env['omniauth.auth'])

    if user.persisted?
      user.update_social_network_link env['omniauth.auth']

      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => 'Facebook'
      sign_in_and_redirect user, :event => :authentication
    else
      redirect_to new_user_session_path and return

      session["devise.provider_data"] = env["omniauth.auth"].except('extra')
      redirect_to new_user_registration_url
    end
  end

  def authorize_twitter
    user = User.find_for_oauth(env['omniauth.auth'])

    if user.persisted?
      user.update_social_network_link env['omniauth.auth']

      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => 'Twitter'
      sign_in_and_redirect user, :event => :authentication
    else
      redirect_to new_user_session_path and return

      session["devise.provider_data"] = env["omniauth.auth"].except('extra')
      flash[:notice] = I18n.t('devise.registrations.twitter') if user.initial_provider == 'twitter'
      redirect_to new_user_registration_url
    end
  end

  def link_site(site)
    @site_connection = current_user.build_social_network_link(env['omniauth.auth'])

    if @site_connection.save
      redirect_to root_path, :notice => I18n.t('devise.omniauth.site_link', :site => site)
    else
      session["devise.provider"] = env["omniauth.auth"]["provider"]
      session["devise.uid"] = env["omniauth.auth"]["uid"]

      render :template => 'users/merge_accounts'
    end
  end
end
