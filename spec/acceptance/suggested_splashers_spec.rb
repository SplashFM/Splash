require 'acceptance/acceptance_helper'

feature "Suggested splashers", :js => true do
  SUPP = User::SUGGESTED_USERS_PER_PAGE

  include UI::SuggestedSplashers

  subject { page }

  scenario "Hide 'view more' on page load with at most #{SUPP} suggestions" do
    friend = create!(User)
    3.times { friend.follow create!(User).id }
    user.follow friend.id

    go_to 'home'

    suggested_splashers { should_not have_view_more_button }
  end

  scenario "Hide 'view more' once there are at most #{SUPP} suggestions" do
    friend = create!(User)
    4.times { friend.follow create!(User).id }
    user.follow friend.id

    go_to 'home'
    view_more_suggested_splashers
    ignore_splasher :first

    suggested_splashers { should have_no_view_more_button }
  end
end
