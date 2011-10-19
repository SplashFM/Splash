Twitter.configure do |config|
  config.consumer_key = AppConfig.twitter['key']
  config.consumer_secret = AppConfig.twitter['secret']
end
