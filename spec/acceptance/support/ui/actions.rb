module UI
  module Actions
    def self.included(base)
      base.let(:user) { create(User).with_required_info! }
    end

    def expand_track
      click_link t("tracks.track.expand")
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
                   "user[password": "#{user.password}"}});
      JS
    end

    def search_for(filter, search_type, &block)
      within(search_form(search_type)) { fill_in "f", :with => filter }

      within(search_results(search_type), &block) if block_given?
    end

    def see_more_results
      click_link(t('searches.page.see_more'))
    end

    def splash(track)
      within(track_css(track)) { find(splash_css).click }
    end

    def upload(path)
      t = build!(Track)

      click_link t('formtastic.actions.upload')

      wait_until { page.has_css?(upload_css, :visible => true) }

      fill_in Track.human_attribute_name(:title), :with => t.title
      fill_in Track.human_attribute_name(:artist), :with => t.artist
      attach_file Track.human_attribute_name(:data), path
    end

    def with_splash(splash, &block)
      within(track_css(splash.track), &block)
    end
  end
end
