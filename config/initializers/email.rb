ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default :charset => "UTF-8"
ActionMailer::Base.smtp_settings = {
  :address => "smtp.sendgrid.net",
  :domain => "mojotech.com",
  :authentication => :login,
  :user_name => AppConfig.sendgrid['username'],
  :password => AppConfig.sendgrid['password'],
  :dev_mailto => "dev@mojotech.com"
}
