require 'acceptance/support/ui/base'

module UI
  module Feed
    def self.included(base)
      base.send(:include, Actions)

      base.before {
        page.extend(Collections)
        page.extend(Matchers)
      }
    end

    module Actions
      def enable(filter)
        case filter
        when :mentions
          click_link t('events.filters.mentions')

          wait_until { page.has_css?("a[href = '#mentions'].active") }
        else
          raise "Unknown filter: #{filter}"
        end

      end

      def with_feed(&do_stuff)
        within w('feed'), &do_stuff
      end
    end

    module Collections
      def mentions
        wait_until { all(w('mention')).presence }
      end

      def splashes
        wait_until { all(w('splash')).presence }
      end
    end

    module Matchers
      include Base::Helpers

      def has_no_splashes?
        has_no_css?(w('splash'))
      end
    end
  end
end
