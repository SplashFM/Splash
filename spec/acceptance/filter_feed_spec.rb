require 'acceptance/acceptance_helper'

feature "Filter feed", :js => true, :driver => :selenium do
  subject { page }

  scenario "Filter by genre" do
    track1  = create(Track).title("Track 1").with_genre!("Rock")
    splash1 = create(Splash).user(user).track!(track1)
    track2  = create(Track).title("Track 2").with_genre!("Folk")
    splash2 = create(Splash).user(user).track!(track2)

    visit profile_path
    filter_feed "Rock"

    should     have_splash(track1)
    should_not have_splash(track2)
  end
end

