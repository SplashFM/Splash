require 'acceptance/acceptance_helper'

feature "Upload track", :js => true do
  subject { page }

  background { visit dashboard_path }

  scenario "Upload track" do
    search_for "Nothing", :track do
      a = build?(Artist)
      t = build(Track).title('Steady as she goes').performers!([a])
      upload file('sky_sailing_steady_as_she_goes.m4a'), t

      should have_content('Uploaded.')
    end

    search_for "steady", :track do
      should have(1).track
    end
  end
end

