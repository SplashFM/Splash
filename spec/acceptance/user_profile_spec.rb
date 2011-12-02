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

    scenario "Show own social activity only" do
      friend         = create(User).with_required_info!
      friends_friend = create(User).with_required_info!

      # include
      user.follow friend
      create(Comment).author!(user)

      # exclude
      friend.follow friends_friend
      create(Comment).author!(friend)
      create(Comment).author!(friend)
      create(Splash).user!(user)

      go_to current_page

      with_feed {
        enable :activity

        should have(2).social_activities
        should have_no_splashes
      }
    end

    scenario "View own splashes only on feed" do
      friend = create!(User) and user.follow friend

      # include
      2.times { create(Splash).user!(user) }

      # exclude
      create(Splash).user!(friend)
      create!(Splash)

      go_to current_page

      feed { should have(2).splashes }
    end

    def current_page
      'profile'
    end
  end
end
