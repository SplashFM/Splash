module UI
  module Actions
    include ActionController::RecordIdentifier

    def self.included(base)
      base.let(:user) { create(User).with_required_info! }
    end

    def cancel_upload
      click_link I18n.t("upload.cancel")
    end

    def change_tagline(text)
      find('[data-widget = "editable"]').click

      within(".tag-line") do
        fill_in 'value', :with => text
      end

      click_button "Change"
    end

    def expand_splash(track)
      find("[data-widget='splash'][data-track_id='#{track.id}']").click
    end

    def expand_track
      click_link t("splashes.splash.expand")
    end

    def follow(user, from_user_profile=true)
      if from_user_profile
        search_for user.name, :global
        click_link user.name
      else
        page.execute_script <<-JS
          $("[data-widget = 'suggested-users'] li:first .wrap a.follow").show();
        JS
      end

      click_link t('follow', :scope => 'users.show')
    end

    def ignore(user)
      page.execute_script <<-JS
        $("[data-widget = 'suggested-users'] li:first .wrap a.delete").show();
      JS

      find("[data-widget = 'suggested-users'] li:first .wrap a.delete").click
    end

    def login(user)
      visit new_user_session_path

      fill_in "user_email", :with => user.email
      wait_until{ page.has_content?('Password') }
      fill_in "user_password", :with => user.password
      click_button t('devise.buttons.login')
    end

    def fetch_event_updates
      page.execute_script 'Widgets.Feed.fetchUpdateCount()'
    end

    def filter_feed(filter)
      within('[data-widget = "events-filter"]') {
        find('[data-widget = "toggle"]').click
        fill_in "q", :with => filter

        find("ul li.as-result-item:first-child").click
      }
    end

    def set_splash_comment(track, comment = nil)
      wait_until { page.has_css?(track_css(track)) }

      with_found_track(track) {
        click_link I18n.t('tracks.widget.splash')

        if comment
          within("##{TracksHelper.dom_id(track)}") {
            find("[data-widget = 'comment-box']").set(comment)
          }
        end
      }
    end

    def refresh_events
      wait_until {
        page.has_css?('[data-widget = "event-update-counter"]', :visible => true)
      }

      within('[data-widget = "event-update-counter"]') { find('a').click }
    end

    def search_for(filter, search_type, &block)
      within(search_form(search_type)) {
        fill_in "f", :with => filter

        within(search_results, &block) if block_given?
      }
    end

    def see_more_results
      click_link(t('home.search.load_more'))
    end

    def see_splasher_profile
      find('[data-widget = "profile-link"]').click
    end

    def splash(track, comment = nil)
      set_splash_comment track, comment

      submit_splash track
    end

    def submit_splash(track)
      with_found_track(track) {
        click_button I18n.t('tracks.widget.splash')
      }
    end

    def add_comment(text)
      click_link t("comments.index.add_comment")

      within("[data-widget = comment-form]") do
        fill_in 'comment_body', :with => text
        click_button 'comment_submit'
      end
    end

    def remove_comment(track, comment)
      within("[data-widget='splash'][data-track_id='#{track.id}']") do
        within(".comments") do
          find('li', :text => comment).click_link('x')
        end
      end
    end

    def with_found_track(t, &block)
      within(track_css(t), &block)
    end

    def with_notifications(&block)
      find('[data-widget = "notification-count"]').click

      wait_until { page.has_css?('.notifications .content', :visible => true) }

      within '.notifications .content', &block
    end

    def with_splash(splash, &block)
      within("[data-splash_id = '#{splash.id}'][data-widget = 'splash']", &block)
    end

    def with_splash_info(&block)
      within("[data-widget = 'splash-info']", &block)
    end
  end
end
