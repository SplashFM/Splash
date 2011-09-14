require 'acceptance/acceptance_helper'

feature "Track widget", :js => true do
  subject { page }

  background { visit dashboard_path }

  scenario "Splashable song" do
    track = create!(Track)

    search_for track.title, :track do
      should have_splashable(track)
    end
  end

  scenario "Splashed song" do
    track = create!(Track)

    search_for track.title, :track do
      splash track
    end

    visit dashboard_path
    search_for track.title, :track do
      should have_splashed(track)
    end
  end
end

