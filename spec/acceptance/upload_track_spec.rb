require 'acceptance/acceptance_helper'

feature "Upload track", :js => true do
  subject { page }

  background { visit dashboard_path }

  scenario "Upload track" do
    search_for "Nothing", :track do
      ar = build?(Artist)
      al = build?(Album)
      t  = build(Track).
        title('Steady as she goes').
        albums([al]).
        performers!([ar])

      upload file('sky_sailing_steady_as_she_goes.m4a'),
             t,
             'This is my comment!'
    end

    should have_hidden_search_results(:track)

    search_for "steady", :track do
      should have(1).track
    end
  end
end

