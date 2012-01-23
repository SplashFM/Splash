require 'acceptance/acceptance_helper'

feature "Track search box", :adapter => :postgresql, :js => true do
  include UI::TrackSearch
  include UI::Feed

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

  scenario "View all results" do
    15.times { |i| create(DiscoveredTrack).title!("Track #{i}") }

    search_tracks_for('Track') { view_all_results }

    expanded_track_results { should have(15).expanded_track_results }
  end

  scenario "Disable controls when viewing all results" do
    10.times { |i| create(DiscoveredTrack).title!("Track #{i}") }

    search_tracks_for('Track') { view_all_results }

    track_search  {
      should have_disabled_search
      should have_disabled_upload
    }
    feed { should have_disabled_filters }
  end
end
