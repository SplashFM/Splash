ActionMailer::Base.default :charset => "UTF-8"

unless Rails.env.test?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.sendgrid.net",
    :domain => "mojotech.com",
    :authentication => :login,
    :user_name => AppConfig.sendgrid['username'],
    :password => AppConfig.sendgrid['password'],
    :dev_mailto => AppConfig.dev_mailto
  }
end
