require 'acceptance/acceptance_helper'

feature "Resplashing", :js => true do
  subject { page }

  background do
    splash = create(Splash).
      track(create!(Track)).
      user!(create(User).with_required_info!)

    user.following << splash.user
  end

  scenario "Resplash" do
    go_to 'home'

    resplash Splash.first

    should have(2).splashes
  end

  scenario "Only resplash once" do
    create(Splash).
      track(Splash.first.track).
      user!(user)

    go_to 'home'

    should_not have_link(t('splashes.splash.resplash'))
  end

  scenario "Assign a ripple to original splasher on resplash" do
    User.reset_ripple_counts

    go_to 'home'

    splash = Splash.first

    resplash splash

    with_splash(splash) { see_splasher_profile }

    should have_ripples(1)
  end
end

