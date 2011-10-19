require 'acceptance/acceptance_helper'

feature "Resplashing", :js => true do
  subject { page }

  background do
    splash = create(Splash).
      track(create!(Track)).
      user!(create!(User))

    user.following << splash.user
  end

  scenario "Resplash", :driver => :selenium do
    visit dashboard_path

    resplash Splash.first

    should have(2).splashes
  end

  scenario "Only resplash once", :driver => :selenium do
    create(Splash).
      track(Splash.first.track).
      user!(user)

    visit dashboard_path

    should_not have_link(t('splashes.splash.resplash'))
  end
end

