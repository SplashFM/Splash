require 'acceptance/acceptance_helper'

feature "Edit user", :js => true do
  background { visit edit_user_path(user) }

  scenario "fill in name field with Mojo Test" do
    fill_in 'user_name', :with => 'Mojo Test'
    click_button 'user_submit'

    page.current_path.should == home_path
  end

  scenario "fill in name field with blank" do
    fill_in 'user_name', :with => ''
    click_button 'user_submit'

    page.has_content?("can't be blank")
  end
end
