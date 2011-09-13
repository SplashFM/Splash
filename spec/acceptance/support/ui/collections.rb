module UI
  module Collections
    def tracks
      wait_until { all(track_css).presence }
    end

    Capybara::Session.send(:include, self)
  end
end
