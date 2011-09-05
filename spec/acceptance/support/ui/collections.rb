module UI
  module Collections
    def tracks
      all(track_css)
    end

    Capybara::Session.send(:include, self)
  end
end
