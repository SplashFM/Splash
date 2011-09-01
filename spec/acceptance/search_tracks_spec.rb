require 'acceptance/acceptance_helper'

feature "Search tracks" do
  subject { SearchPage.new(page) }

  scenario "iTunes results only" do
    search_for "beatles"

    should have(3).items
    should have(3).itunes_search_items
  end

  scenario "mixed results"

  scenario "No results"

  def search_for(filter)
    visit tracks_path
    fill_in "f", :with => filter
    click_button "Search"
  end

  class SearchPage
    def initialize(page)
      @page = page
    end

    def items
      @page.all('tbody tr')
    end

    def itunes_search_items
      @page.all('tr[data-source = "itunessearch"]')
    end
  end
end

