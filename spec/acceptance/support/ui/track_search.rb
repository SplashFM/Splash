require 'acceptance/support/ui/base'

module UI
  module TrackSearch
    def self.included(base)
      base.send(:include, Actions)

      base.before {
        page.extend(Collections)
        page.extend(Matchers)
      }
    end

    module Actions
      def expanded_track_results(&do_stuff)
        within '.all-results', &do_stuff
      end

      def load_more_results
        wait_until {
          page.has_css?(w('load-more'), :visible => true)
        }

        click_link t('shared.feed_search.load_more')
      end

      def view_all_results
        wait_until {
          has_css?('a',
                   :content => t('shared.feed_search.view_all_results'),
                   :visible => true)
        }

        click_link t('shared.feed_search.view_all_results')
      end

      def track_results(&do_stuff)
        within w('results'), &do_stuff
      end

      def search_tracks_for(terms, &do_stuff)
        find(w('track-search', 'input')).set(terms)

        with_track_search &do_stuff
      end

      def with_track_search(&do_stuff)
        within w('track-search'), &do_stuff
      end
    end

    module Collections
      def expanded_track_results
        wait_until { all('tbody tr').presence }
      end

      def track_results
        wait_until { all(w('track-result')).presence }
      end
    end

    module Matchers
      def has_no_load_more_results_link?
        wait_until { has_visible_controls? }

        within('.controls') {
          has_no_css?('a[data-widget = "load-more"]', :visible => true)
        }
      end

      def has_view_all_results_link?
        has_link?(t('shared.feed_search.view_all_results'))
      end

      def has_visible_controls?
        has_css?('.controls', :visible => true)
      end
    end
  end
end
