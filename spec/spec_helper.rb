require 'rubygems'
require 'spork'

# This file is copied to spec/ when you run 'rails generate rspec:install'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
end

Spork.each_run do
  # This code will be run each time you run your specs.

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    config.include Bricks::DSL
    config.include Helpers

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = false

    config.before do
      DatabaseCleaner.strategy = :transaction
    end

    config.before :js => true do
      DatabaseCleaner.strategy = :truncation
    end

    config.before do
      DatabaseCleaner.start
    end

    config.after do
      DatabaseCleaner.clean
    end

    config.before :all, :adapter => :postgresql do
      unless ActiveRecord::Base.connection.class.name.include?('PostgreSQL')
        test_pg = ActiveRecord::Base.configurations['test_pg']
        ActiveRecord::Base.establish_connection(test_pg)
      end
    end

    config.before :all, :adapter => nil do
      unless ActiveRecord::Base.connection.class.name.include?('SQLite')
        test = ActiveRecord::Base.configurations['test']
        ActiveRecord::Base.establish_connection(test)
      end
    end
  end
end
