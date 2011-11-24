require 'acceptance/support/ui/base'

module UI
  module Notifications
    def self.included(base)
      base.send(:include, Actions)

      base.before {
        page.extend(Collections)
        page.extend(Matchers)
      }
    end

    module Actions
      def click(position)
        case position
        when :first
          page.notifications.first.click
        else
          raise "Unknown position: #{position}"
        end

      end

      def with_notifications(&do_stuff)
        find(w('toggle-notifications')).click

        within w('list-notifications'), &do_stuff
      end
    end

    module Collections
      def notifications
        wait_until { all(w('notification')).presence }
      end
    end

    module Matchers
    end
  end
end
