shared_examples_for "feed" do
  include UI::Feed

  scenario "Shows #{Event::PER_PAGE} items at a time" do
    11.times { create(Splash).user!(user) }

    go_to current_page

    feed { should have(10).splashes }
  end
end
