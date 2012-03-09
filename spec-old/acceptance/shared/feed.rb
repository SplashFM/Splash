shared_examples_for "feed" do
  include UI::Feed

  describe "Splashes" do
    scenario "Load splash tree" do
      friend1 = create!(User)
      friend2 = create!(User)
      track   = create!(Track)

      user.following = [friend1, friend2]

      create(Splash).user(friend1).track!(track)
      splash = create(Splash).user(user).track!(track)
      create(Splash).user(friend2).with_parent!(splash)

      go_to current_page

      with_splash(:first) {
        expand_splash

        should have_ordered_splasher_thumbnails(friend1, user, friend2)
      }
    end
  end

  describe "Endless scrolling" do
    include UI::Feed

    scenario "Load all events" do
      15.times { create(Splash).user!(user) }

      go_to current_page

      scroll_to_bottom

      feed {
        wait_until { page.has_no_loading_spinner? }

        should have(15).splashes
      }

      scroll_to_bottom

      feed {
        wait_until { page.has_no_loading_spinner? }

        should have(15).splashes
        should have_content(t('events.all_loaded'))
      }
    end
  end
end
