require 'acceptance/acceptance_helper'

feature "Notifications", :js => true do
  include UI::Notifications

  subject { page }

  scenario "are sent when a user mentions a follower" do
    u = create!(User) and user.follow u.id
    s = create(Splash).user(u).mention!(user)

    go_to 'home'

    notifications.should have(1).mention
  end

  scenario "are not sent when a user mentions a non-follower" do
    u = create!(User)
    s = create(Splash).user(u).mention!(user)

    go_to 'home'

    notifications.should have_no_mentions
  end

  scenario "Go to mentions tab when we click a mention notification" do
    u = create!(User)
    user.follow u.id

    s = create(Splash).user(u).mention!(user)

    go_to 'home'

    with_notifications { click :first }

    page.should be_user_mentions
  end
end
