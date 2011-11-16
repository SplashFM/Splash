require 'spec_helper'

describe Mention do
  it "creates no mentions if field is blank" do
    create(Splash).
      track(create!(Track)).
      user!(create(User).with_required_info!)

    Mention.all.should be_empty
  end

  it "creates no mention if the recipient is not following the author" do
    author    = create(User).with_required_info!
    recipient = create(User).with_required_info!

    lambda {
      create(Splash).
        track(create!(Track)).
        user(author).
        comment!("A comment mentioning @{#{recipient.slug}}")
    }.should_not change(Mention, :count)
  end

  it "creates a mention from a splash's comment field" do
    author    = create(User).with_required_info!
    recipient = create(User).following([author]).with_required_info!
    splash    = create(Splash).
      track(create!(Track)).
      user(author).
      comment!("A comment mentioning @{#{recipient.slug}}")

    mention = Mention.first

    mention.notified.should == recipient
    mention.notifier.should == author
    mention.target.should   == splash
  end

  it "creates many mentions from a splash's comment field" do
    author     = create(User).with_required_info!
    recipient1 = create(User).following([author]).with_required_info!
    recipient2 = create(User).following([author]).with_required_info!
    splash     = create(Splash).
      track(create!(Track)).
      user(author).
      comment!("A comment to @{#{recipient2.slug}}
                mentioning @{#{recipient1.slug}}")

    mentions     = Mention.all
    recipients   = mentions.map(&:notified)
    authors      = mentions.map(&:notifier).uniq
    mentionables = mentions.map(&:target).uniq

    recipients.should include(recipient1)
    recipients.should include(recipient2)

    authors.should have(1).author
    authors.first.should == author

    mentionables.should have(1).mentionable
    mentionables.first.should == splash
  end

  it "returns a comment with a user name" do
    u = create(User).with_required_info!
    s  = Splash.new(:comment => "I'm mentioning @{#{u.id}}.")

    s.comment_with_mentions.should == "I'm mentioning @#{u.name}."
  end

  it "returns a comment with user names replaced" do
    u1 = create(User).with_required_info!
    u2 = create(User).with_required_info!
    s  = Splash.new(:comment => "I'm mentioning @{#{u1.id}} and @{#{u2.id}}.")

    s.comment_with_mentions.
      should == "I'm mentioning @#{u1.name} and @#{u2.name}."
  end

  it "returns a comment without any mentions" do
    Splash.new(:comment => 'A comment.').comment_with_mentions.
      should == 'A comment.'
  end

  it "returns a nil comment if it's nil" do
    Splash.new.comment_with_mentions.should be_nil
  end
end
