require 'acceptance/acceptance_helper'

feature "Login", :logout => true do
  scenario "with an existing email and non blank name", :js => true do
    login user

    page.should have_content('user@mojotech.com')
    page.current_path.should == home_path
  end

  scenario "valid user with blank name", :js => true do
    login user

    page.current_path.should == edit_user_path(user)
  end

  scenario "valid user with a wrong passwod", :js => true do
    visit new_user_session_path

    fill_in "user_email", :with => user.email
    fill_in "user_password", :with => 'xxx-xxx'
    click_button t('devise.buttons.login')

    page.find('#flash_error').should have_content(t('devise.failure.invalid'))
  end
end
