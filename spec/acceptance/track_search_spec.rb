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

  scenario "Popular song found" do
    track = create(DiscoveredTrack).popularity_rank!(999)

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

  scenario "View all results" do
    15.times { |i| create(DiscoveredTrack).title!("Track #{i}") }

    search_tracks_for('Track') {
      load_more_results
      view_all_results
    }

    expanded_track_results {
      should have(15).expanded_track_results
    }
  end
end
