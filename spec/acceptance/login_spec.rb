require 'acceptance/acceptance_helper'

feature "Login", :logout => true do

  scenario "with an existing email and non blank name", :js => true do
    login user

    page.should have_content('user@mojotech.com')
    page.should have_content(I18n.t('devise.sessions.signed_in'))
    page.current_path.should == home_path
  end

  scenario "with blank name", :js => true do
    user = create!(User)

    login user

    page.current_path.should == edit_user_path(user)
  end
end
