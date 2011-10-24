require 'acceptance/acceptance_helper'

feature "Profile activity feed", :js => true do
  subject { page }

  scenario "Show only user splashes" do
    track1 = create(Track).title!("I splashed")
    track2 = create(Track).title!("They splashed")

    create(Splash).track(track1).user!(user)
    create(Splash).track(track2).user!(create!(User))

    go_to 'profile'

    should have_splash(track1)
    should_not have_splash(track2)
  end
end
