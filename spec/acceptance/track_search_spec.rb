require 'acceptance/acceptance_helper'

feature "Track search box", :adapter => :postgresql, :js => true do
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
    pending

    track = create!(Track)

    search_for track.title, :track do
      should have(1).track
      should_not have_more_results
    end
  end

  scenario "Does not return results for users" do
    pending

    user = create(User).with_name!('Jack Johnson')

    search_for user.name, :track do
      should have_content(t('searches.empty'))
      should_not have_more_results
    end
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

