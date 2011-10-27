require 'acceptance/acceptance_helper'

feature "Mentioning", :js => true do
  subject { page }

  scenario "While splashing" do
    u = create(User).with_required_info.following!([user])
    t = create!(Track)

    Notification.delete_all

    search_for(t.title, :track) {
      splash t, "This is a comment @{#{u.id}}."
    }

    logout

    fast_login u

    should have_notifications(1)

    with_notifications { should have_mention(user) }
  end

  scenario "Resplashing"

  scenario "Commenting"

  scenario "Mention a user at the end of the comment (with autocomplete)"

  scenario "Mention many users at the end of the comment (with autocomplete)"

  scenario "Unmatched"

  scenario "Cursor is over user name"

  scenario "Delete mention"
end

