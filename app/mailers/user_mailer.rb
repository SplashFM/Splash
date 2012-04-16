class UserMailer < ActionMailer::Base
  default :from => "Splash.FM <notifications@splash.fm>"

  def confirm_access_request(access_request)
    @code = access_request.referral_code

    mail :to => access_request.email, :subject => "You're on the Invite List!"
  end

  def invite(access_request, code)
    @url  = new_user_registration_url(:code => code)

    mail :to => access_request.email, :subject => 'Jump In!'
  end

  def send_invitation(access_request)
    @url          = home_url
    @inviter_name = access_request.inviter.name

    mail :to      => access_request.email,
         :subject => "#{@inviter_name} invites you to Splash.FM"
  end

  def notification(notification)
    @notification = notification

    mail :to            => notification.notified.email,
         :subject       => "#{notification.notifier.name} #{notification.action}",
         :template_name => notification.template
  end

  def welcome(user)
    @user = user

    mail to: user.email, subject: 'Welcome to Splash.FM!'
  end
end
