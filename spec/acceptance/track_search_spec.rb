require 'acceptance/acceptance_helper'

feature "Track search box", :adapter => :postgresql, :js => true do
  include UI::TrackSearch

  subject { page }

  scenario "No results"  do
    pending

    search_for "Nothing", :track do
      should_not have_tracks
      should     have_content(t('searches.empty'))
      should_not have_more_results
    end
  end

  scenario "Song found" do
    track = create!(Track)

    search_tracks_for track.title do
      track_results { should have(1).track_result }
    end
  end

  scenario "Show \"View All Result\" link" do
    10.times { |i| create(DiscoveredTrack).title!("Track #{i}") }

    search_tracks_for('Track') { load_more_results }

    track_results { should have_view_all_results_link }
  end

  scenario "Hide \"Load More Results\" link after seing 10 more results" do
    20.times { |i| create(DiscoveredTrack).title!("Track #{i}") }

    search_tracks_for('Track') {
      load_more_results
      load_more_results
    }

    track_results { should have_no_load_more_results_link }
  end

  scenario "Paginated results" do
    pending

    per_page     = Track.default_per_page
    pages        = 3
    total_tracks = per_page * pages

    1.upto(total_tracks) { |i| create(Track).title!("Track #{i}") }

    search_for "Track", :track do
      wait_until(10) { page.has_more_results? }

      1.upto(pages) { |p| see_more_results }

      1.upto(total_tracks) { |i| should have_track("Track #{i}") }

      pending { should_not have_more_results }
    end
  end
end
