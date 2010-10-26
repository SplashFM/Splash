source 'http://rubygems.org'

gem 'rails', '3.0.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Databases
gem 'sqlite3-ruby', :require => 'sqlite3'
gem "mysql"
# gem "pg"

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

# Gem used by scap:
# To minimize merge conflicts, keep this list sorted alphabetically
gem "declarative_authorization", ">= 0.5.1"
gem "devise", ">=1.1.0"
gem "formtastic", "~> 1.1.0"
gem "haml", ">= 3.0.18"
gem "hipchat"
gem "hoptoad_notifier"
gem "jammit", ">=0.5.0"
gem "newrelic_rpm"
gem "paperclip"
gem "seed-fu", ">=1.2.3"
gem "simple-navigation", "3.0.0.beta2"
gem "will_paginate", "~> 3.0.pre2"

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  # gem 'webrat'
  gem "rspec-rails", ">= 2.0.0.beta.22"
  gem "ruby-debug"
end

group :development do
  gem "ruby_parser" # soft dependency of declarative_authorization browser
end

# Put Gems used by your application, but not by scap, here:
