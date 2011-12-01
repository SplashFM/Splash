shared_examples_for "feed" do
  include UI::Feed

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
