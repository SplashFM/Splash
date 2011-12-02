require 'acceptance/support/ui/base'

module UI
  module Feed
    def self.included(base)
      base.send(:include, Actions)

      base.before {
        page.extend(Collections)
        page.extend(Matchers)
        page.extend(Util)
      }
    end

    module Actions
      def enable(filter)
        case filter
        when :activity
          click_link t('events.filters.social')

          wait_until { page.has_css?("a[href = '#social'].active") }
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

      alias_method :feed, :with_feed
    end

    module Collections
      def mentions
        wait_until { all(w('mention')).presence }
      end

      def social_activities
        activities = social_activity_selector

        wait_until { all(activities).presence }
      end

      def splashes
        wait_until { all(w('splash')).presence }
      end
    end

    module Matchers
      include Base::Helpers

      def has_loading_spinner?
        has_css?('#loading-spinner')
      end

      def has_no_loading_spinner?
        has_no_css?('#loading-spinner')
      end

      def has_no_social_activity?
        has_no_css?(social_activity_selector)
      end

      def has_no_splashes?
        has_no_css?(w('splash'))
      end
    end

    module Util
      def social_activity_selector
        w('social-comment') + ',' + w('social-relationship')
      end
    end
  end
end
