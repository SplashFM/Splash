class UserMailer < ActionMailer::Base
  default :from => "notifications@splash.fm"

  def notification(notification)
    mail(:to      => notification.notified.email,
         :subject => t(notification.title, :notification => notification))
  end
end
