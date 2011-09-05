module UI
  module Queries
    def track_css(track = nil)
      'ul.tracks li' + (track ? "[data-track_id = '#{track.id}']" : '')
    end

    def splash_track_css(track)
      track_css(track) + " .splash input[type = 'submit']"
    end

    Capybara::Session.send(:include, self)
  end
end
