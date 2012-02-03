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
    @url  = new_user_registration_url(:code => access_request.code)
    @inviter_name = access_request.inviter.name

    mail :to => access_request.email, :subject => 'You were invited to Splash.fm'
  end

  def notification(notification)
    @notification = notification

    mail :to            => notification.notified.email,
         :subject       => t("notifications.#{notification.class.name.underscore}",
                             :user => notification.notifier.name),
         :template_name => notification.template
  end
end
