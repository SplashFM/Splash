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
end

