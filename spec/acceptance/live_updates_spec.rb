require 'acceptance/acceptance_helper'

shared_examples_for "Live updates" do
  background do
    go_to current_page
  end

  scenario "Update counter after splash", :js => false do
    sleep 2
    splash_and_fetch

    page.should have_event_updates(1)
  end

  scenario "Replace update counter when more updates happen" do
    2.times { |i|
      sleep 2
      splash_and_fetch

      page.should have_event_updates(i + 1)
    }
  end

  scenario "Show no updates if feed is up to date" do
    user_splash

    sleep 2
    go_to current_page
    fetch_event_updates

    page.should have_no_event_updates
  end

  scenario "Refresh feed when user clicks on update counter" do
    sleep 2
    splash_and_fetch

    refresh_events

    page.should have_no_event_updates
    page.should have(1).splash
  end

  def splash_and_fetch
    user_splash
    fetch_event_updates
  end
end

feature "Live updates (Dashboard)", :js => true, :driver => :selenium do
  subject { page }

  background do
    user.following << create!(User)
  end

  it_should_behave_like "Live updates"

  def current_page
    'home'
  end

  def user_splash
    create(Splash).user(user.following.first).track!(create!(Track))
  end
end


feature "Live updates (User profile)", :js => true, :driver => :selenium do
  subject { page }

  it_should_behave_like "Live updates"

  def current_page
    'profile'
  end

  def user_splash
    create(Splash).user(user).track!(create!(Track))
  end
end
