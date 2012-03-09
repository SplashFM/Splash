require 'acceptance/support/ui/base'

module UI
  module Profile
    def self.included(base)
      base.send(:include, Actions)

      base.before {
        page.extend(Collections)
        page.extend(Matchers)
      }
    end

    module Actions
      def view_followers
        within('.user-follows') {
          find('a[href = "#followers"]').click

          click_link t('users.follows.view_more')
        }
      end

      def view_followings
        within('.user-follows') {
          find('a[href = "#following"]').click

          click_link t('users.follows.view_more')
        }
      end

      def follower_window(&do_stuff)
        within '#fancybox-wrap', &do_stuff
      end

      alias_method :following_window, :follower_window
    end

    module Collections
      def followings
        all(w('relationship'))
      end

      alias_method :followers, :followings
    end

    module Matchers
      def has_unsplashable_track?(track)
        has_css?(w('splash') + "[data-track_id = '#{track.id}'].unsplashable")
      end
    end
  end
end
