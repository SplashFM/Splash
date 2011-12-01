require 'acceptance/acceptance_helper'
require 'acceptance/shared/feed'

feature "User Profile", :js => true do
  subject { page }

  scenario "Follow User" do
    pending

    followed = create(User).with_required_info!
    follow(followed)

    should have_content(t('users.show.unfollow'))
  end

  scenario "See following notification" do
    pending

    followed = create(User).with_required_info!
    follow(followed)

    click_link t('devise.labels.sign_out')

    fast_login(followed)
    go_to 'profile'

    should have_notifications(1)
  end

  scenario "See following feed update" do
    pending

    followed = create(User).with_required_info!
    follow(followed)

    logout
    fast_login(followed)

    should have_following(user.name, t('you'))
  end

  scenario "Edit tagline" do
    pending

    go_to 'profile'
    change_tagline("hi cruel world")

    should have_content("hi cruel world")
  end

  describe "Feed" do
    include UI::Feed

    it_should_behave_like "feed"

    def current_page
      'profile'
    end
  end
end
