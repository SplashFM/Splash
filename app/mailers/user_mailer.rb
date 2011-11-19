class UserMailer < ActionMailer::Base
  default :from => "notifications@splash.fm"

  def notification(notification)
    @notification = notification

    mail :to            => notification.notified.email,
         :subject       => t("notifications.#{notification.class.name.underscore}",
                             :user => notification.notifier.name),
         :template_name => notification.class.name.underscore
  end
end
