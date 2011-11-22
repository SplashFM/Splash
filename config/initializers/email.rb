ActionMailer::Base.default :charset => "UTF-8"
ActionMailer::Base.default :from => AppConfig.noreply_address
ActionMailer::Base.default_url_options[:host] =
  AppConfig.preferred_host || "example.com"

unless Rails.env.test? || Rails.env.test_pg?
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
