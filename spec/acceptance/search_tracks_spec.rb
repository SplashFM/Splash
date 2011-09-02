require 'acceptance/acceptance_helper'

feature "Search tracks", :adapter => :postgresql do
  subject { SearchPage.new(page) }

  scenario "Empty query"

  scenario "No results"

  scenario "Song found" do
    track = create!(Track)

    search_for track.title

    subject.should have(1).track
  end

  def search_for(filter)
    visit tracks_path
    fill_in "f", :with => filter
    click_button "Search"
  end

  class SearchPage
    def initialize(page)
      @page = page
    end

    def tracks
      @page.all('ul.tracks li')
    end
  end
end

