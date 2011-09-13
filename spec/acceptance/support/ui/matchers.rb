module UI
  module Matchers
    def has_splashed?(track)
      has_css?(splash_track_css(track) +
           "[value = '#{I18n.t("tracks.widget.splashed")}']")
    end

    def has_splashable?(track)
      has_css?(splash_track_css(track) +
           "[value = '#{I18n.t("tracks.widget.splash")}']")
    end

    def has_tracks?
      has_css?(track_css)
    end

    Capybara::Session.send(:include, self)
  end
end
