module UI
  module Collections
    def splashes
      wait_until { all('[data-widget = "splash"]').presence }
    end

    def tracks
      wait_until { all(track_css).presence }
    end

    def users
      wait_until { all(user_query).presence }
    end

    Capybara::Session.send(:include, self)
  end
end
