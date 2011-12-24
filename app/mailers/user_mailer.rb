class UserMailer < ActionMailer::Base
  default :from => "Splash.FM <notifications@splash.fm>"

  def confirm_access_request(access_request)
    @code = access_request.referral_code

    mail :to => access_request.email, :subject => "You're on the Invite List!"
  end

  def invite(access_request, code)
    @url  = new_user_registration_path(:code => code)

    mail :to => access_request.email, :subject => 'Jump In!'
  end

  def notification(notification)
    @notification = notification

    mail :to            => notification.notified.email,
         :subject       => t("notifications.#{notification.class.name.underscore}",
                             :user => notification.notifier.name),
         :template_name => notification.class.name.underscore
  end
end
