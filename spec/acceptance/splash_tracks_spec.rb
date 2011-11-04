require 'acceptance/acceptance_helper'

feature "Splash tracks", :js => true do
  subject { page }

  background { go_to 'home' }

  scenario "Splash existing track" do
    track = create!(Track)

    search_for track.title, :track do
      splash track
    end

    should have_splash(track)
  end

  scenario "Splash song with comment" do
    track = create!(Track)

    search_for track.title, :track do
      splash track, "This is my comment"
    end

    wait_until { page.has_search_results_hidden? }

    with_splash Splash.first do
      expand_track
    end

    should have_content("This is my comment")
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

  scenario "Splashing at own profile" do
    go_to 'profile'

    track = create!(Track)

    search_for track.title, :global do
      splash track, "This is my comment!"
    end

    wait_until { page.has_search_results_hidden? }

    should have_splash(track)
  end

  scenario "show time since it was splashed" do
    track = create!(Track)

    search_for track.title, :track do
      splash track
    end

    splash = Splash.for(user, track)

    within("[data-widget = 'splash'][data-track_id = '#{track.id}']") do
       has_content?(time_ago_in_words(splash.created_at))
    end
  end
end
