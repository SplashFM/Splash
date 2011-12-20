class UserMailer < ActionMailer::Base
  default :from => "Splash.FM <notifications@splash.fm>"

  def invite(access_request)
    @url  = home_url(:to => 'signup', :code => access_request.code)

    mail :to      => access_request.email,
         :subject => "Come on in, the water is fine!"
  end

  def notification(notification)
    @notification = notification

    mail :to            => notification.notified.email,
         :subject       => t("notifications.#{notification.class.name.underscore}",
                             :user => notification.notifier.name),
         :template_name => notification.class.name.underscore
  end
end
