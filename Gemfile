source 'http://rubygems.org'

gem 'rails', '>=3.0.1'

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
gem "active_scaffold"
gem "active_scaffold_export"
gem "braintree"
gem "daemons", "1.0.10"
gem "declarative_authorization", ">= 0.5.1"
gem "delayed_job"
gem "devise", ">=1.1.7"
gem "formtastic", "~> 1.1.0"
gem "geokit-rails3"
gem "haml", ">= 3.0.18"
gem "hipchat"
gem "hoptoad_notifier"
gem "jammit", ">=0.5.0"
gem "newrelic_rpm"
gem "paperclip"
gem "seed-fu", ">=1.2.3"
gem "simple-navigation", ">=3.0.0"
gem 'whenever', :require => false
gem "will_paginate", ">=3.0.pre"

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  # gem 'webrat'
  gem "rspec-rails", ">= 2.0.0"
  gem "ruby-debug"
  gem "factory_girl_rails"
  gem "watchr"
end

group :development do
  gem "thin" # webrick is SO slow.
  gem "ruby_parser" # soft dependency of declarative_authorization browser
  gem "awesome_print", :require => "ap"  # pretty print objects in console via `ap my_object`
  gem "wirble"
end

# Put Gems used by your application, but not by scap, here:
gem "state_machine"
