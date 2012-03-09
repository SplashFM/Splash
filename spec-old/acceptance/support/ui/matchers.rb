module UI
  module Matchers
    def has_no_artwork?
      has_no_css?("img")
    end

    def has_artwork?(location)
      has_css?(%Q{img[src = "#{location}"]})
    end

    def has_event_updates?(count)
      has_content?(I18n.t('events.updates', :count => count))
    end

    def has_comments?(count)
      has_css?(".comments li", :count => count)
    end

    def has_following?(follower, following)
      within('[data-widget = "following"]') {
        has_content?(I18n.t('events.following',
                            :follower => follower,
                            :followed => following))
      }
    end

    def has_no_event_updates?
      has_no_css?('[data-widget = "event-update-counter"]', :visible => true)
    end

    def has_hidden_search_results?(type)
      has_css?("##{type}-results", :hidden => true)
    end

    def has_search_results_hidden?
      has_css?('[data-widget = "results"]', :hidden => true)
    end

    def has_splash?(track)
      has_css?("[data-widget = 'splash'][data-track_id = '#{track.id}']")
    end

    def has_no_splash?(track)
      has_no_css?("[data-widget = 'splash'][data-track_id = '#{track.id}']")
    end

    def has_no_upload_form?
      has_css?("[data-widget = 'upload']", :visible => false)
    end

    def has_notifications?(count)
      has_css?("[data-widget = 'notification-count']", :content => count.to_s)
    end

    def has_mention?(user)
      within('li') {
        has_content?(I18n.t('notifications.mention', :user => user.name))
      }
    end

    def has_ripples?(count)
      within("[data-widget = 'ripples']") { has_content?(count.to_s) }
    end

    def has_splashed?(track)
      within(track_css(track)) {
        has_css?(splash_css + "[value = '#{I18n.t("tracks.widget.splashed")}']")
      }
    end

    def has_splash_action?(track)
      within(track_css(track)) {
        has_link?(I18n.t("tracks.widget.splash"))
      }
    end

    def has_splashable?(track)
      within(track_css(track)) {
        has_css?(splash_css + "[value = '#{I18n.t("tracks.widget.splash")}']")
      }
    end

    def has_download_link?
      has_link?(I18n.t("splashes.splash.download"))
    end

    def has_purchase_link?
      has_link?(I18n.t("splashes.splash.purchase"))
    end

    def has_tracks?
      has_css?(track_css)
    end

    def has_users?
      has_css?(user_query)
    end

    def has_more_results?
      has_css?("a", :text => I18n.t('home.search.load_more'))
    end

    def has_more_comments_link?(count)
      has_css?("a", :text => I18n.t('comments.comments.comment_number', :number => count))
    end

    def has_track?(title)
      has_content?(title)
    end

    def has_suggested_users?(count)
      within("[data-widget = 'suggested-users'] ul") do
        has_css?("li", :count => count)
      end
    end

    def has_validation_error?(subject_class, *fields)
      fields.all? { |f|
        has_css?('li.error #' + subject_class.name.underscore + "_#{f}")
      }
    end

    Capybara::Session.send(:include, self)
  end
end