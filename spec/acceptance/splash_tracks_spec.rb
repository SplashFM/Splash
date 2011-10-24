require 'acceptance/acceptance_helper'

feature "Splash tracks", :js => true do
  subject { page }

  background { go_to 'home' }

  scenario "Splash existing track" do
    track = create!(Track)

    search_for track.title, :track do
      splash track
    end

    should have_splashed(track)
    should have_splash(track)
  end

  scenario "Splash song with comment" do
    track = create!(Track)

    search_for track.title, :track do
      splash track, "This is my comment!"
    end

    wait_until { page.has_search_results_hidden? }

    with_splash Splash.first do
      expand_track
    end

    should have_content("This is my comment!")
  end

  scenario "Splashing at another user's profile" do
    other = create(User).with_required_info!
    track = create!(Track)

    visit user_slug_path(other)

    search_for track.title, :global do
      splash track, "This is my comment!"
    end

    wait_until { page.has_search_results_hidden? }

    should_not have_splash(track)
  end

  scenario "Splashing at own profile", :driver => :selenium do
    go_to 'profile'

    track = create!(Track)

    search_for track.title, :global do
      splash track, "This is my comment!"
    end

    wait_until { page.has_search_results_hidden? }

    should have_splash(track)
  end
end

