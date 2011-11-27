require 'acceptance/support/ui/base'

module UI
  module Splash
    def self.included(base)
      base.send(:include, Actions)

      base.before {
        page.extend(Collections)
        page.extend(Matchers)
      }
    end

    module Actions
      def add_splash_comment(comment)
        find('.commentArea').set(comment)
      end
    end

    module Collections
    end

    module Matchers
    end
  end
end
