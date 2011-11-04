require 'acceptance/acceptance_helper'

feature "Suggested Splashsers", :js => true do
  subject { page }

  scenario "see three suggested splashers" do
    generate_suggested_users(4)
    go_to 'home'

    should have_suggested_users(3)
  end

  scenario "has only two suggested splashers" do
    generate_suggested_users(2)
    go_to 'home'

    should have_suggested_users(2)
  end

  def generate_suggested_users(count=4)
    u1 = create(User).with_required_info!
    u2 = create(User).with_required_info!
    u3 = create(User).with_required_info!
    u4 = create(User).with_required_info!
    u5 = create(User).with_required_info!
    u6 = create(User).with_required_info!
    u7 = create(User).with_required_info!
    u8 = create(User).with_required_info!
    u9 = create(User).with_required_info!

    user.followers << [u1, u2, u3]
    user.following << [u2, u5, u6]

    u1.following << [u4, u5, u6, u7]
    u2.following << [u6, u7]
    u3.following << [u6, u7]
    u3.following << [u8, u9] if count == 4
  end
end
