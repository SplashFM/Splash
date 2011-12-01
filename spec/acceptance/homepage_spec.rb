require 'acceptance/acceptance_helper'
require 'acceptance/shared/feed'

feature "Homepage", :js => true do
  subject { page }

  describe "Feed" do
    include UI::Feed

    it_should_behave_like "feed"

    scenario "View own and friends' splashes on feed" do
      friend = create!(User) and user.follow friend

      # include
      2.times { create(Splash).user!(user) }
      create(Splash).user!(friend)

      # exclude
      create!(Splash)

      go_to current_page

      feed { should have(3).splashes }
    end

    scenario "Show mentions only" do
      u = create!(User)
      user.follow u

      s = create(Splash).user(u).mention!(user)

      go_to 'home'

      with_feed {
        enable :mentions

        should have(1).splash
      }
    end

    def current_page
      'home'
    end
  end
end

