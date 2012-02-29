source 'http://rubygems.org'

gem 'rails', '~> 3.2.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Databases
gem 'sqlite3-ruby', :require => 'sqlite3'
# gem "mysql2", "~> 0.2.0"
gem 'pg'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

# Gem used by scap:
# To minimize merge conflicts, keep this list sorted alphabetically
# gem "braintree"
gem "daemons", "1.0.10"
gem "delayed_job"
gem "devise", "~> 2.0.0"
gem "formtastic", "~> 2.0.0.rc1"
gem "haml", ">= 3.0.18"
gem "sass", ">= 3.1.7"
gem "hipchat", '0.4.0'
gem "hoptoad_notifier"
gem "jammit", ">=0.5.0"
gem "newrelic_rpm"
gem "paperclip"
gem "paperclip-meta"
gem "seed-fu", ">=1.2.3"
gem "state_machine"
gem "uuidtools"
gem 'whenever', :require => false
#gem "will_paginate", ">=3.0.pre"
gem "js-routes", :require => 'js_routes'
gem "inherited_resources"
gem 'omniauth', "~> 1.0.0"
gem "friendly_id", "~> 4.0.0.beta8"
gem 'fb_graph'
gem "twitter"

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  # gem 'webrat'
  gem "rspec-rails", ">= 2.0.0"
end

group :development do
  gem "thin" # webrick is SO slow.
  gem "awesome_print", :require => "ap"  # pretty print objects in console via `ap my_object`
  gem "wirble"
  gem "engineyard"
  gem "guard"
  gem "libnotify"
end

# Put Gems used by your application, but not by scap, here:
gem "jquery-rails"
gem "babilu"
gem "taglib-ruby", '>= 0.3.0', :require => 'taglib'
gem "redis"
gem "kaminari"
gem "sanitize"
gem "parallel_tests", :group => :development
gem "acts-as-taggable-on", "~> 2.1.0"
gem "silent-postgres"
gem "has_scope"
gem "aws-s3"
gem "active_model_serializers", :git => 'git://github.com/david/active_model_serializers.git'
gem "redis-store"
gem "redis-objects", :require => 'redis/objects', :git => 'git://github.com/david/redis-objects.git'
gem "valium"
gem "omniauth-facebook"
gem "omniauth-twitter"
gem "haml_coffee_assets"

group :assets do
  gem "sass-rails"
  gem "coffee-rails"
  gem "uglifier-rails"
  gem "compass-rails"
end

group :test do
  gem "rr", "~> 1.0"
  gem "capybara", "~> 1.0"
  gem "database_cleaner", "~> 0.6.0"
  gem "bricks", :require => 'bricks/adapters/active_record'
  gem "spork", "~> 0.9.0.rc"
  gem "rspec-instafail"
  gem "timecop"
  gem "webmock"
end

gem "itunes-search-api"
gem "nokogiri"
