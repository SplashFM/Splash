require 'acceptance/acceptance_helper'

feature "Edit user", :js => true do
  subject { page }

  background do
    go_to 'profile'
    # click_link t('users.vcard.edit')
  end

  scenario "fill in name field with Mojo Test" do
    pending

    fill_in 'user_name', :with => 'Mojo Test'
    click_button 'user_submit'

    should have_content(t('flash.actions.update.notice', {resource_name: "User"}))
  end

  scenario "fill in name field with blank" do
    pending

    fill_in 'user_name', :with => ''
    click_button 'user_submit'

    should have_content(t('errors.messages.blank'))
  end
end
