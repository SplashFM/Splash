require 'acceptance/acceptance_helper'

feature "User settings", :js => true do
  include UI::Settings

  background do
    go_to 'home'
  end

  scenario "Successfully update a setting" do
    edit_settings { fill_in t(User, :nickname), :with => 'ior3k' }

    go_to 'home', :no_pjax

    with_settings {
      page.should have_field(t(User, :nickname), :with => 'ior3k')
    }
  end

  scenario "Successfully update the password" do
    edit_settings {
      fill_in t(User, :password), :with => 'cowabunga!'
      fill_in 'user_password_confirmation', :with => 'cowabunga!'
    }

    log_out
    go_to 'home', :no_pjax
    fast_login user.email, 'cowabunga!'

    page.should be_home
  end
end

