require 'acceptance/acceptance_helper'

feature "Upload track", :js => true do
  subject { page }

  background { visit dashboard_path }

  scenario "Upload track"  do
    pending do
      search_for "Nothing", :track do
        upload file('pipershut_lo.mp3')
        should have_content('Uploaded.')
      end
    end
  end
end

