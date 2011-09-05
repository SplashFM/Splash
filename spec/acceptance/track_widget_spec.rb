require 'acceptance/acceptance_helper'

feature "Track widget" do
  subject { page }

  background { visit dashboard_path }

  scenario "Splashable song" do
    track = create!(Track)

    search_for track.title

    should have_splashable(track)
  end

  scenario "Splashed song" do
    track = create!(Track)

    search_for track.title
    splash track

    visit dashboard_path
    search_for track.title

    should have_splashed(track)
  end
end

