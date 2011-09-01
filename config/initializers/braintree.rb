if defined?(Braintree)
  unless AppConfig.braintree
    raise 'You need a "braintree" stanza in your config.yml!  See the sample.'
  end
  Braintree::Configuration.environment = AppConfig.braintree['environment'].to_sym
  Braintree::Configuration.merchant_id = AppConfig.braintree['merchant_id']
  Braintree::Configuration.public_key = AppConfig.braintree['public_key']
  Braintree::Configuration.private_key = AppConfig.braintree['private_key']
end
