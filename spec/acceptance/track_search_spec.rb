require 'acceptance/acceptance_helper'

feature "Track search box", :adapter => :postgresql, :js => true do
  subject { page }

  background { visit dashboard_path }

  scenario "Empty query"

  scenario "No results"  do
    search_for "Nothing", :track do
      should_not have_tracks
      should     have_content(t('searches.create.empty'))
      should_not have_more_results
    end
  end

  scenario "Song found" do
    track = create!(Track)

    search_for track.title, :track do
      should have(1).track
      should_not have_more_results
    end
  end

  scenario "Does not return results for users" do
    user = create(User).with_name!('Jack Johnson')

    search_for user.name, :track do
      should have_content(t('searches.create.empty'))
      should_not have_more_results
    end
  end

  scenario "Paginated results" do
    per_page     = SearchesController::PER_PAGE
    pages        = 3
    total_tracks = per_page * pages

    1.upto(total_tracks) { |i| create(Track).title!("Track #{i}") }

    search_for "Track", :track do
      1.upto(pages) { |p|
        first = (per_page * (p - 1)) + 1
        last  = first + per_page - 1

        first.upto(last) { |i| should have_track("Track #{i}") }

        should_not have_track("Track #{last + 1}")

        if p != pages
          see_more_results
        else
          should_not have_more_results
        end
      }
    end
  end
end

