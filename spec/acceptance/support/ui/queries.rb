module UI
  module Queries
    SEARCH_TYPES = [:track, :global]

    def search_form(type)
      ensure_valid_search_type(type)

      "[data-widget = '#{type}-search']"
    end

    def search_results
      "[data-widget = 'results']"
    end

    def track_css(track = nil)
      'li[data-track_id' + (track ? " = '#{track.id}'" : '') + ']'
    end

    def user_query(user = nil)
      'li[data-user_id' + (user ? " = '#{user.id}'" : '') + ']'
    end

    def splash_css
      "[data-widget = 'splash-action'] input[type = 'submit']"
    end

    def upload_css
      "[data-widget = 'upload']"
    end

    private

    def ensure_valid_search_type(type)
      unless SEARCH_TYPES.include?(type)
        raise "Unknown search box: #{type}. " <<
              "Allowed: #{SEARCH_TYPES.inspect}"
      end
    end

    Capybara::Session.send(:include, self)
  end
end
