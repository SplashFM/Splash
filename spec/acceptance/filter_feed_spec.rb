require 'acceptance/acceptance_helper'

feature "Filter feed", :js => true do
  subject { page }

  scenario "Filter by performer" do
    pending

    track1  = create(Track).title("Track 1").with_performer!("Yes")
    splash1 = create(Splash).user(user).track!(track1)
    track2  = create(Track).title("Track 2").with_performer!("Nirvana")
    splash2 = create(Splash).user(user).track!(track2)

    visit profile_path
    filter_feed "Yes"

    should     have_splash(track1)
    should_not have_splash(track2)
  end

  scenario "Filter by genre" do
    track1  = create(Track).title("Track 1").tag_list!(["Rock"])
    splash1 = create(Splash).user(user).track!(track1)
    track2  = create(Track).title("Track 2").tag_list!(["Folk"])
    splash2 = create(Splash).user(user).track!(track2)

    visit profile_path
    filter_feed "Rock"

    should     have_splash(track1)
    should_not have_splash(track2)
  end
end

