class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :require_user

  def facebook
    if current_user
      link_or_redirect 'facebook'
    else
      authorize_facebook
    end
  end

  def twitter
    if current_user
      link_or_redirect 'twitter'
    else
      authorize_twitter
    end
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private

  def authorize_facebook
    ft = social_token

    if user = User.with_social_connection(ft[:provider], ft[:uid])
      user.social_connection(ft[:provider]).
        refresh ft.slice(:token)

      sign_in_and_redirect user, :event => :authentication
    else
      user = User.create_with_social_connection(ft)

      if user.persisted?
        sign_in_and_redirect user, :event => :authentication
      else
        redirect_to root_path
      end
    end
  end

  def authorize_twitter
    tt   = social_token
    user = User.with_social_connection(tt[:provider], tt[:uid])

    if user
      user.social_connection(tt[:provider]).
        refresh tt.slice(:token, :token_secret)

      sign_in_and_redirect user, :event => :authentication
    else
      session['devise.provider_data'] = tt

      # for Beta
      if AccessRequest.code?(signup_code)
        redirect_to new_sn_registration_path
      else
        redirect_to root_path
      end
    end
  end

  def link_or_redirect(provider)
    if ! current_user.social_connection(provider)
      link_site(provider.capitalize)
    else
      redirect_to home_path
    end
  end

  def link_site(site)
    @site_connection = current_user.social_connections.build(social_meta_token)

    if @site_connection.save
      redirect_to stored_location_for(:user) || root_path,
                  :notice => I18n.t('devise.omniauth.site_link', :site => site)
    else
      session["devise.provider"] = env["omniauth.auth"]["provider"]
      session["devise.uid"] = env["omniauth.auth"]["uid"]

      render :template => 'users/merge_accounts'
    end
  end

  def social_meta_token
    t = env['omniauth.auth']

    {:provider     => t['provider'],
     :uid          => t['uid'],
     :token        => t['credentials']['token']}.tap { |st|
      if t['credentials']['token_secret']
        st[:token_secret] = t['credentials']['token_secret']
      end
    }
  end

  def social_token
    t = env['omniauth.auth']

    social_meta_token.merge!({:access_code => signup_code,
                              :email       => t['user_info']['email'],
                              :name        => t['user_info']['name'],
                              :nickname    => t['user_info']['nickname']})
  end

  def signup_code
    if env['omniauth.origin'].present?
      query = URI.parse(env["omniauth.origin"]).query

      CGI.parse(query)['code'].first if query && query['code']
    end
  end
end
