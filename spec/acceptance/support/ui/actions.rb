module UI
  module Actions
    def self.included(base)
      base.let(:user) { create!(User) }
    end

    def login
      visit new_user_session_path

      fill_in "user_email", :with => user.email
      fill_in "user_password", :with => user.password
      click_button 'Sign in'
    end

    def search_for(filter)
      fill_in "f", :with => filter
      click_button "Search"
    end

    def splash(track)
      find(splash_track_css(track)).click
    end
  end
end
