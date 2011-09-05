module UI
  module Matchers
    def has_splashed?(track)
      has_css?(splash_track_css(track) +
           "[value = '#{I18n.t("tracks.widget.splashed")}']")
    end

    Capybara::Session.send(:include, self)
  end
end
