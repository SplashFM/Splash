require 'acceptance/acceptance_helper'

feature "Comment on splash tracks", :js => true do
  subject { page }

  scenario "Add comment" do
    track = create!(Track)

    search_for track.title, :global do
      splash track
    end

    expand_splash

    add_comment

    should have_comments(1)
  end
end
