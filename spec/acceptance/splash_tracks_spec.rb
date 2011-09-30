require 'acceptance/acceptance_helper'

feature "Splash tracks", :js => true do
  subject { page }

  background { visit dashboard_path }

  scenario "Splash existing track" do
    track = create!(Track)

    search_for track.title, :track do
      splash track
    end

    should have_splashed(track)
  end

  scenario "Splash song with comment" do
    track = create!(Track)

    search_for track.title, :track do
      splash track, "This is my comment!"
    end

    visit profile_path

    with_splash Splash.first do
      expand_track
    end

    should have_content("This is my comment!")
  end
end

