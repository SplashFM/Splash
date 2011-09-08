require 'spec_helper'

Spork.each_run do
  Dir[Rails.root.join("spec/acceptance/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
    Capybara.javascript_driver = :webkit

    config.include Capybara::DSL
    config.include UI::Actions
    config.include UI::Queries
    config.include Helpers

    config.before :type => :request do
      login(user) unless example.metadata[:logout]
    end
  end
end
