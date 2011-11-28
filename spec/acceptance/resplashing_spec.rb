require 'acceptance/acceptance_helper'

feature "Resplashing", :js => true do
  subject { page }

  scenario "Resplash" do
    pending

    user.following << create_splash.user

    go_to 'home'

    resplash Splash.first

    should have(2).splashes
  end

  scenario "Only resplash once" do
    pending

    splash = create_splash

    user.following << splash.user

    create(Splash).track(splash.track).user!(user)

    go_to 'home'

    should_not have_link(t('splashes.splash.resplash'))
  end

  scenario "Assign a ripple to parent splashers on resplash" do
    pending

    RedisRecord.reset_all

    grandp = create_splash
    parent = create_splash(grandp)

    user.following << grandp.user
    user.following << parent.user

    go_to 'home'

    resplash parent

    with_splash(parent) { see_splasher_profile }
    should have_ripples(1)

    go_to 'home'

    with_splash(grandp) { see_splasher_profile }
    should have_ripples(2)
  end

  def create_splash(parent = nil)
    splash = create(Splash).
      track(create!(Track)).
      user(create(User).with_required_info!)

    splash.parent(parent) if parent

    splash.generate
  end
end
