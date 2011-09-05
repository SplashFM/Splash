module UI
  module Queries
    def track_css(track = nil)
      'ul.tracks li' + (track ? "[data-track_id = '#{track.id}']" : '')
    end

    Capybara::Session.send(:include, self)
  end
end
