require 'acceptance/acceptance_helper'

feature "Notifications", :js => true do
  include UI::Notifications

  subject { page }

  scenario "Go to mentions tab when we click a mention notification" do
    u = create!(User)
    user.follow u

    s = create(Splash).user(u).mention!(user)

    go_to 'home'

    with_notifications { click :first }

    page.should be_user_mentions
  end
end
