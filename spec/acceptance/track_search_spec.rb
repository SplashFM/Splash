require 'acceptance/acceptance_helper'

feature "Track search box", :adapter => :postgresql, :js => true do
  subject { page }

  background { visit dashboard_path }

  scenario "Empty query"

  scenario "No results"  do
    search_for "Nothing", :track do
      should_not have_tracks
      should     have_content(t('searches.create.empty'))
    end
  end

  scenario "Song found" do
    track = create!(Track)

    search_for track.title, :track do
      should have(1).track
    end
  end

  scenario "Does not return results for users" do
    user = create(User).with_name!('Jack Johnson')

    search_for user.name, :track do
      should have_content(t('searches.create.empty'))
    end
  end
end

