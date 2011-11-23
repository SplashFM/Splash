module UI
  module Base
    def self.included(base)
      base.send(:include, Actions)
      base.send(:include, Helpers)
    end

    module Actions
    end

    module Helpers
      def t(*args)
        I18n.t(*args)
      end

      def w(name)
        "[data-widget = '#{name}']"
      end
    end

    module Matchers
      Capybara::Session.send(:include, self)
    end
  end
end
