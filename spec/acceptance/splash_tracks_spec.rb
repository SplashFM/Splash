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
end

