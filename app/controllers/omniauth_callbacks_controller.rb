class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :require_user

  def facebook
    oauthorize("Facebook")
  end

  def twitter
    oauthorize("Twitter")
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private
  def oauthorize(kind)
    @user = User.find_for_oauth(env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.provider_data"] = env["omniauth.auth"].except('extra')
      flash[:notice] = I18n.t('devise.registrations.twitter') if @user.provider == 'twitter'
      redirect_to new_user_registration_url
    end
  end
end
