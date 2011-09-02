require 'acceptance/acceptance_helper'

feature "Search tracks", :adapter => :postgresql do
  subject { SearchResults.new(page) }

  scenario "Empty query"

  scenario "No results"  do
    search_for "Nothing"

    subject.should be_empty
  end

  scenario "Song found" do
    track = create!(Track)

    search_for track.title

    subject.should have(1).track
  end

  def search_for(filter)
    visit dashboard_path
    fill_in "f", :with => filter
    click_button "Search"
  end

  class SearchResults < PageWrapper
    def empty?
      tracks.empty? &&
        page.has_content?(t('tracks.index.empty'))
    end

    def tracks
      page.all('ul.tracks li')
    end
  end
end

