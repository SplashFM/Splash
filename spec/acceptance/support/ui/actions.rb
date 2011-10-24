module UI
  module Actions
    include ActionController::RecordIdentifier

    def self.included(base)
      base.let(:user) { create(User).with_required_info! }
    end

    def cancel_upload
      click_link I18n.t("upload.cancel")
    end

    def expand_track
      click_link t("splashes.splash.expand")
    end

    def login(user)
      visit new_user_session_path

      fill_in "user_email", :with => user.email
      wait_until{ page.has_content?('Password') }
      fill_in "user_password", :with => user.password
      click_button t('devise.buttons.login')
    end

    def fast_login(user)
      visit new_user_session_path

      page.execute_script <<-JS
        $.ajax(
          "#{user_session_path}",
          {type: "POST",
           async: false,
           cache: false,
           data:  {"user[email]": "#{user.email}",
                   "user[password]": "#{user.password}"}});
      JS
    end

    def fetch_event_updates
      page.execute_script 'Widgets.Feed.fetchUpdateCount()'
    end

    def filter_feed(filter)
      fill_in "token-input-q", :with => filter

     find(".token-input-dropdown-facebook ul li:first-child").click
    end

    def refresh_events
      within('[data-widget = "event-update-counter"]') { find('a').click }
    end

    def resplash(splash)
      with_splash(splash) {
        click_link t('splashes.splash.resplash')
        click_button t('splashes.splash.resplash')
      }
    end

    def search_for(filter, search_type, &block)
      within(search_form(search_type)) { fill_in "f", :with => filter }

      within(search_results(search_type), &block) if block_given?
    end

    def see_more_results
      click_link(t('searches.page.see_more'))
    end

    def splash(track, comment = nil)
      wait_until(10) { page.has_css?(track_css(track)) }

      within(track_css(track)) {
        click_link I18n.t('tracks.widget.splash')

        if comment
          within("##{TracksHelper.dom_id(track)}") {
            fill_in "splash[comment]", :with => comment
          }
        end

        click_button I18n.t('tracks.widget.splash')
      }
    end

    def upload(path, track = nil, comment = nil)
      upload_track(path, comment)

      wait_until { page.has_metadata_form? }

      if track
        fill_in Track.human_attribute_name(:title), :with => track.title
        fill_in Track.human_attribute_name(:performers),
                :with => track.performer_names.first
        fill_in Track.human_attribute_name(:albums), :with => track.albums.first
      end

      click_button t('tracks.actions.complete_upload')
    end

    def upload_track(path, comment = nil)
      wait_until(10) { page.has_link?(t('upload.upload')) }

      click_link t('upload.upload')

      wait_until { page.has_css?(upload_css, :visible => true) }

      if comment
        fill_in Splash.human_attribute_name(:comment), :with => comment
      end
      attach_file Track.human_attribute_name(:data), path
    end


    def with_splash(splash, &block)
      within("[data-splash_id = '#{splash.id}'][data-widget = 'splash']", &block)
    end

    def with_splash_info(&block)
      within("[data-widget = 'splash-info']", &block)
    end
  end
end
