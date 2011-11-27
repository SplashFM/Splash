require 'acceptance/acceptance_helper'

feature "Upload track", :js => true do
  include UI::Feed
  include UI::TrackSearch
  include UI::Upload

  subject { page }

  background { go_to 'home' }

  scenario "Upload and splash" do
    upload file('sky_sailing_steady_as_she_goes.m4a'),
           build(Track).title!('Steady as she goes'),
           'This is my comment!'

    search_tracks_for 'Steady as she goes' do
      track_results { should have(1).track_result }
    end

    feed { should have(1).splash }
  end

  scenario "Upload using bad data" do
    track = build(Track).title("").with_performer!("")

    upload file('sky_sailing_steady_as_she_goes.m4a'),
           track,
           'This is my comment!'

    wait_until { page.has_search_results_hidden? }

    should have_validation_error(UndiscoveredTrack, :title, :performers)
  end

  scenario "Splash uploaded that already exists" do
    track = create(Track).
      title("Steady As She Goes").
      albums("An Airplane Carried Me to Bed").
      with_performer!("Sky Sailing")

    upload file('sky_sailing_steady_as_she_goes.m4a'),
           track,
           'This is my comment!'

    search_for "Steady As She Goes", :track do
      should have(1).track
    end

    should_have_splash
  end

  scenario "Upload using metadata" do
    upload file('sky_sailing_steady_as_she_goes.m4a'),
           nil,
           'This is my comment!'

    should_have_splash

    should have_content("Steady As She Goes")
    should have_content("Sky Sailing")
  end

  scenario "Upload invalid file" do
    upload_track File.join(Rails.root, 'Rakefile'),
                 'This is my comment!'

    should have_validation_error(UndiscoveredTrack, :data)
  end

  scenario "Cancel upload" do
    upload_track file('sky_sailing_steady_as_she_goes.m4a'),
                 'This is my comment!'

    cancel_upload

    should have_no_upload_form
  end

  scenario "Double splash" do
    upload file('sky_sailing_steady_as_she_goes.m4a'),
           nil,
           'This is my comment!'

    upload file('sky_sailing_steady_as_she_goes.m4a'),
           nil,
           'This is my comment!'

    should have_content(t('upload.already_splashed'))
  end

  def should_have_splash
    with_splash Splash.first do
      expand_track
    end

    should have_content("This is my comment!")
  end
end

