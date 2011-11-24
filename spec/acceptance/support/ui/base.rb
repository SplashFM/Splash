module UI
  module Base
    def self.included(base)
      base.send(:include, Actions)
      base.send(:include, Helpers)
    end

    module Actions
    end

    module Helpers
    end

    module Matchers
      Capybara::Session.send(:include, self)
    end
  end
end
