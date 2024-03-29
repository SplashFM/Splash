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
        find('.splash-comment').set(comment)
      end

      def resplash
        find(w('toggle-splash')).click

        wait_until {
          page.has_xpath?(XPath::HTML.button(t('splashes.splash.splash')),
                                             :visible => true)
        }

        click_button t('splashes.splash.splash')
      end
    end

    module Collections
    end

    module Matchers
      def has_unsplashable_track?(track)
        has_css?(w('splash') + "[data-track_id = '#{track.id}'].unsplashable")
      end
    end
  end
end
