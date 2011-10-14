require 'acceptance/acceptance_helper'

feature "Upload track", :js => true, :driver => :selenium do
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

    should_have_splash
  end

  scenario "Splash uploaded" do
    track = build(Track).
      title("Steady As She Goes").
      albums("An Airplane Carried Me to Bed").
      with_performer!("Sky Sailing")

    search_for "Nothing", :track do
      upload file('sky_sailing_steady_as_she_goes.m4a'),
             track,
             'This is my comment!'
    end

    should_have_splash
  end

  scenario "Splash uploaded that already exists" do
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

    should_have_splash
  end

  def should_have_splash
    visit profile_path

    with_splash Splash.first do
      expand_track
    end

    should have_content("This is my comment!")
  end
end

