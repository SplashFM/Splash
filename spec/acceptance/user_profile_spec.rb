require 'acceptance/acceptance_helper'

feature "User Profile", :js => true do
  subject { page }

  scenario "Follow User" do
    followed = create(User).with_required_info!
    follow(followed)

    should have_content(t('users.show.unfollow'))
  end

  scenario "See following notification" do
    followed = create(User).with_required_info!
    follow(followed)

    click_link t('devise.labels.sign_out')

    fast_login(followed)
    go_to 'profile'

    should have_notifications(1)
  end

  scenario "Edit tagline" do
    go_to 'profile'
    change_tagline("hi cruel world")

    should have_content("hi cruel world")
  end
end
