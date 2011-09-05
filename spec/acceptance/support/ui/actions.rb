module UI
  module Actions
    def search_for(filter)
      fill_in "f", :with => filter
      click_button "Search"
    end
  end
end
