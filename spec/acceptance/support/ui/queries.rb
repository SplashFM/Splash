module UI
  module Queries
    SEARCH_TYPES = {:track  => 'track-search'}

    def search_form(type)
      ensure_valid_search_type(type)

      "[data-widget = '#{type}-search']"
    end

    def search_results(type)
      ensure_valid_search_type(type)

      "##{SEARCH_TYPES[type]}"
    end

    def track_css(track = nil)
      'li[data-track_id' + (track ? " = '#{track.id}'" : '') + ']'
    end

    def splash_track_css(track)
      track_css(track) + " .splash input[type = 'submit']"
    end

    private

    def ensure_valid_search_type(type)
      unless SEARCH_TYPES[type]
        raise "Unknown search box: #{type}. " <<
              "Allowed: #{SEARCH_TYPES.keys.join(', ')}"
      end
    end

    Capybara::Session.send(:include, self)
  end
end
