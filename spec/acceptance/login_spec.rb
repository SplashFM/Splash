require 'acceptance/acceptance_helper'

feature "Login", :logout => true do
  scenario "with an existing email", :js => true do
    login

    page.should have_content('user@mojotech.com')
    page.should have_content(I18n.t('devise.sessions.signed_in'))
    page.current_path.should == home_path
  end
end
