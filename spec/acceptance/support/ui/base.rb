module UI
  module Base
    def self.included(base)
      base.send(:include, Actions)
      base.send(:include, Helpers)
    end

    module Actions
      def click_widget(widget)
        find(w(widget)).click
      end

      def with_lifesaver(&do_stuff)
        click_widget 'lifesaver'
        within w('lifesaver-menu'), &do_stuff
      end
    end

    module Helpers
      def t(*args)
        klass, field = args

        case klass
        when Class
          klass.human_attribute_name(field)
        else
          I18n.t(*args)
        end
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
