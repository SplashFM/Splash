module UI
  module Collections
    def tracks
      wait_until { all(track_css).presence }
    end

    def users
      wait_until { all(user_query).presence }
    end

    Capybara::Session.send(:include, self)
  end
end
