module UI
  module Matchers
    def has_splashed?(track)
      within(track_css(track)) {
        has_css?(splash_css + "[value = '#{I18n.t("tracks.widget.splashed")}']")
      }
    end

    def has_splashable?(track)
      within(track_css(track)) {
        has_css?(splash_css + "[value = '#{I18n.t("tracks.widget.splash")}']")
      }
    end

    def has_tracks?
      has_css?(track_css)
    end

    def has_users?
      has_css?(user_query)
    end

    Capybara::Session.send(:include, self)
  end
end
