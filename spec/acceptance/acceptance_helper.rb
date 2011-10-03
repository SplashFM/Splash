require 'spec_helper'

Spork.each_run do
  Dir[Rails.root.join("spec/acceptance/support/**/*.rb")].each { |f| require f }

  Capybara.server do |app, port|
    require 'rack/handler/webrick'

    logger = WEBrick::Log::new(Rails.root.join("log/acceptance_test.log").to_s)

    Rack::Handler::WEBrick.
      run(app, :Port => port, :AccessLog => [], :Logger => logger)
  end

  RSpec.configure do |config|
    Capybara.javascript_driver = :webkit

    config.include Capybara::DSL
    config.include UI::Actions
    config.include UI::Queries

    config.before :type => :request do
      fast_login(user) unless example.metadata[:logout]
    end
  end
end
