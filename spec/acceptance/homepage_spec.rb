require 'acceptance/acceptance_helper'
require 'acceptance/shared/feed'

feature "Homepage", :js => true do
  subject { page }

  describe "Feed" do
    include UI::Feed
    include UI::Splash

    it_should_behave_like "feed"

    scenario "See updates" do
      friend = create(User).followers!([user])

      friend.follow create!(User).id
      create(Splash).user! friend
      create(Splash).user! user

      fetch_feed_updates

      feed { should have_update_counter(:count => 1) }
    end

    scenario "View only splashes on everyone feed" do
      friend = create!(User)

      # exclude
      user.follow friend.id

      # include
      2.times { create(Splash).user!(user) }
      create(Splash).user!(friend)
      create!(Splash)

      go_to current_page

      with_feed {
        enable :everyone

        should have(4).splashes
        should have_no_social_activity
      }
    end

    scenario "View own and friends' splashes on feed" do
      friend = create!(User)

      # exclude
      user.follow friend.id
      create!(Splash)

      # include
      2.times { create(Splash).user!(user) }
      create(Splash).user!(friend)

      go_to current_page

      feed {
        should have(3).splashes
        should have_no_social_activity
      }
    end

    scenario "Show social activity only" do
      friend         = create(User).with_required_info!
      friends_friend = create(User).with_required_info!

      # include
      user.follow friend.id
      friend.follow friends_friend
      create(Comment).author!(user)

      # exclude
      create(Splash).user!(user)

      go_to current_page

      with_feed {
        enable :activity

        should have(3).social_activities
        should have_no_splashes
      }
    end

    scenario "Show mentions only" do
      u = create!(User)
      user.follow u.id

      s = create(Splash).user(u).mention!(user)

      go_to 'home'

      with_feed {
        enable :mentions, user

        should have(1).splash
      }
    end

    scenario "Resplashing" do
      RedisRecord.reset_all

      f1 = create!(User) and user.follow f1.id
      f2 = create!(User)
      t  = create!(Track)
      s1 = create(Splash).track(t).user!(f1)
      s2 = create(Splash).track(t).user!(f2)

      go_to 'home'

      with_splash(s1) { resplash }

      feed { should have_unsplashable_track(t) }
    end

    def current_page
      'home'
    end
  end
end
