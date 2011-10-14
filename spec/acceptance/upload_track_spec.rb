require 'acceptance/acceptance_helper'

feature "Upload track", :js => true do
  subject { page }

  background { visit dashboard_path }

  scenario "Upload track" do
    search_for "Nothing", :track do
      t = build(Track).title!('Steady as she goes')

      upload file('sky_sailing_steady_as_she_goes.m4a'),
             t,
             'This is my comment!'
    end

    should have_hidden_search_results(:track)

    search_for "steady", :track do
      should have(1).track
    end
  end

  scenario "Splash uploaded", :driver => :selenium do
    track = build(Track).
      title("Steady As She Goes").
      albums("An Airplane Carried Me to Bed").
      with_performer!("Sky Sailing")

    search_for "Nothing", :track do
      upload file('sky_sailing_steady_as_she_goes.m4a'),
             track,
             'This is my comment!'
    end

    visit profile_path

    with_splash Splash.first do
      expand_track
    end

    should have_content("This is my comment!")
  end

  scenario "Splash uploaded that already exists", :driver => :selenium do
    track = create(Track).
      title("Steady As She Goes").
      albums("An Airplane Carried Me to Bed").
      with_performer!("Sky Sailing")

    search_for "Nothing", :track do
      upload file('sky_sailing_steady_as_she_goes.m4a'),
             track,
             'This is my comment!'
    end

    search_for "Steady As She Goes", :track do
      should have(1).track
    end

    visit profile_path

    with_splash Splash.first do
      expand_track
    end

    should have_content("This is my comment!")
  end
end

