require 'acceptance/acceptance_helper'

feature "Track search box", :adapter => :postgresql, :js => true do
  subject { page }

  background { visit dashboard_path }

  scenario "Empty query"

  scenario "No results"  do
    search_for "Nothing", :track do
      should_not have_tracks
      should     have_content(t('tracks.index.empty'))
    end
  end

  scenario "Song found" do
    track = create!(Track)

    search_for track.title, :track do
      should have(1).track
    end
  end
end

