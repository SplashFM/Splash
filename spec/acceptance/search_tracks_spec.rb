require 'acceptance/acceptance_helper'

feature "Search tracks", :adapter => :postgresql do
  subject { page }

  background { visit dashboard_path }

  scenario "Empty query"

  scenario "No results"  do
    search_for "Nothing"

    should have(0).tracks
    should have_content(t('tracks.index.empty'))
  end

  scenario "Song found" do
    track = create!(Track)

    search_for track.title

    should have(1).track
  end
end

