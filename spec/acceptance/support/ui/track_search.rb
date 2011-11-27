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
      def track_results
        wait_until { all(w('track-result')).presence }
      end
    end

    module Matchers
    end
  end
end
