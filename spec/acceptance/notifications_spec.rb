require 'acceptance/acceptance_helper'

feature "Notifications", :js => true do
  include UI::Notifications

  subject { page }

  scenario "are sent when a user mentions a follower" do
    u = create!(User) and user.follow u.id
    s = create(Splash).user(u).mention!(user)

    go_to 'home'

    notifications.should have(1).mention
  end

  scenario "are not sent when a user mentions a non-follower" do
    u = create!(User)
    s = create(Splash).user(u).mention!(user)

    go_to 'home'

    notifications.should have_no_mentions
  end

  scenario "are sent when someone comments on one of my splashes" do
    s = create(Splash).user!(user)
    c = create(Comment).splash!(s)

    go_to 'home'

    notifications.should have(1).comment_for_splasher
  end

  scenario "are not sent to me when I'm the author of a comment" do
    s = create(Splash).user!(user)
    c = create(Comment).author(user).splash!(s)

    go_to 'home'

    notifications.should be_empty
  end

  scenario "mentions are more important than being the splasher" do
    f = create!(User) and user.follow f.id
    s = create(Splash).user!(user)
    c = create(Comment).author(f).mention(user).splash!(s)

    go_to 'home'

    notifications.should have(1).mention
    notifications.should have_no_comment_for_splasher
  end

  scenario "are sent to all users participating in a conversation" do
    s  = create!(Splash)
    c1 = create(Comment).author(user).splash!(s)
    c2 = create(Comment).splash!(s)

    go_to 'home'

    notifications.should have(1).comment
  end

  scenario "Go to mentions tab when we click a mention notification" do
    u = create!(User)
    user.follow u.id

    s = create(Splash).user(u).mention!(user)

    go_to 'home'

    with_notifications { click :first }

    page.should be_user_mentions
  end
end
