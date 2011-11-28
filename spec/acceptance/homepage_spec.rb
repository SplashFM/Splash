require 'acceptance/acceptance_helper'

feature "Homepage", :js => true do
  subject { page }

  describe "Feed" do
    include UI::Feed

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
  end
end

