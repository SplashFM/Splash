require 'acceptance/acceptance_helper'

feature "Global search", :adapter => :postgresql, :js => true do
  subject { page }

  background { go_to 'home' }

  scenario "Only tracks found" do
    pending

    track = create(Track).title!('Close to the Edge')

    search_for track.title, :global do
      should_not have_users
      should     have(1).track
      should     have_content(track.title)
    end
  end

  scenario "Only users found" do
    pending

    user = create(User).with_name!('Jack Johnson')

    search_for user.name, :global do
      should_not have_tracks
      should     have(1).user
      should     have_content(user.name)
    end
  end

  scenario "Both tracks and users found" do
    pending

    track = create(Track).title!('Close to Jack')
    user  = create(User).with_name!('Jack Johnson')

    search_for 'Jack', :global do
      should     have(1).user
      should     have(1).track
      should     have_content(user.name)
      should     have_content(track.title)
    end
  end

  scenario "No tracks or users found" do
    pending

    search_for 'Nothing', :global do
      should_not have_users
      should_not have_tracks
      should     have_content(t('searches.create.empty'))
    end
  end
end

