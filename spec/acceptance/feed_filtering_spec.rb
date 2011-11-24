require 'acceptance/acceptance_helper'

feature "Feed filtering", :js => true do
  include UI::Feed

  subject { page }

  scenario "Show mentions only" do
    u = create!(User)
    s = create(Splash).user! u

    user.follow u
    create(Comment).
      splash(s).
      body("Hey, I'm mentioning @#{user.nickname}").
      author! u

    go_to 'home'

    with_feed {
      enable :mentions

      should have_no_splashes
      should have(1).mention
    }
  end

  scenario "Filter by performer" do
    pending

    track1  = create(Track).title("Track 1").with_performer!("Yes")
    splash1 = create(Splash).user(user).track!(track1)
    track2  = create(Track).title("Track 2").with_performer!("Nirvana")
    splash2 = create(Splash).user(user).track!(track2)

    visit profile_path
    filter_feed "Yes"

    should     have_splash(track1)
    should_not have_splash(track2)
  end

  scenario "Filter by genre" do
    pending

    friend = create!(User)
    user.following << friend
    track1  = create(Track).title("Track 1").tag_list!(["Rock"])
    splash1 = create(Splash).user(friend).track!(track1)
    track2  = create(Track).title("Track 2").tag_list!(["Folk"])
    splash2 = create(Splash).user(friend).track!(track2)

    go_to 'home'
    filter_feed "Rock"

    should     have_splash(track1)
    should_not have_splash(track2)
  end
end

