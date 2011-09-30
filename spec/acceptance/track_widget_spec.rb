require 'acceptance/acceptance_helper'

feature "Track widget", :js => true do
  subject { page }

  background { visit dashboard_path }

  scenario "Splashable song" do
    track = create!(Track)

    search_for track.title, :track do
      should have_splashable(track)
    end
  end

  scenario "Splashed song" do
    track  = create!(Track)
    splash = create(Splash).user(user).track!(track)

    visit dashboard_path

    search_for track.title, :track do
      should_not have_splash_action(track)
    end
  end

  scenario "Downloadable song" do
    f      = Rack::Test::UploadedFile.new(file("the_vines_get_free.mp3"),
                                          'audio/mpeg')
    track  = create(UndiscoveredTrack).data!(f)
    splash = create(Splash).user(create!(User)).track!(track)

    visit dashboard_path

    with_splash splash do
      expand_track
    end

    with_splash_info do
      should have_download_link
    end
  end

  scenario "Purchasable song" do
    track  = create(DiscoveredTrack).
      purchase_url_raw!("http://somewhere.over.the/rainbow")
    splash = create(Splash).user(create!(User)).track!(track)

    visit dashboard_path

    with_splash splash do
      expand_track
    end

    with_splash_info do
      should have_purchase_link
    end
  end

  describe "Album art" do
    scenario "On user feed" do
      track  = create(Track).
        album_art_url!("http://somewhere.over.the/rainbow.png")
      splash = create(Splash).user(create!(User)).track!(track)

      visit dashboard_path

      with_splash splash do
        should have_album_art("http://somewhere.over.the/rainbow.png")
      end
    end

    scenario "As search result" do
      track = create(Track).
        album_art_url!("http://somewhere.over.the/rainbow.png")

      visit dashboard_path

      search_for track.title, :track do
        should have_no_album_art
      end
    end
  end
end

