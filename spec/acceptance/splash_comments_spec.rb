require 'acceptance/acceptance_helper'

feature "Comment on splash tracks", :js => true do
  subject { page }

  scenario "Add comment" do
    track = create!(Track)

    search_for track.title, :global do
      splash track
    end

    expand_splash(track)
    add_comment("Comment #1")

    should have_comments(1)
  end

  scenario "Remove comment" do
    track = create!(Track)

    search_for track.title, :global do
      splash track
    end

    expand_splash(track)

    add_comment("Comment #1")
    add_comment("Comment #2")
    add_comment("Comment #3")

    remove_comment(track, "Comment #2")

    should have_comments(2)
  end

  scenario "see view more comments link" do
    track = create!(Track)

    search_for track.title, :global do
      splash track
    end

    expand_splash(track)

    add_comment("Comment #1")
    add_comment("Comment #2")
    add_comment("Comment #3")

    should have_more_comments_link(3)
  end
end
