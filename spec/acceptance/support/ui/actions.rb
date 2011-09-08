module UI
  module Actions
    def self.included(base)
      base.let(:user) { create!(User) }
    end

    def login(user)
      visit new_user_session_path

      fill_in "user_email", :with => user.email
      wait_until{ page.has_content?('Password') }
      fill_in "user_password", :with => user.password
      click_button t('devise.buttons.login')
    end

    def search_for(filter)
      fill_in "f", :with => filter
    end

    def splash(track)
      find(splash_track_css(track)).click
    end
  end
end
