require 'spec_helper'

describe Mention do
  it "creates no mentions if field is blank" do
    create(Splash).
      track(create!(Track)).
      user!(create!(User))

    Mention.all.should be_empty
  end

  it "creates no mention if the recipient is not following the author" do
    author    = create(User).with_required_info!
    recipient = create(User).with_required_info!

    lambda {
      create(Splash).
        track(create!(Track)).
        user(author).
        comment!("A comment mentioning @{#{recipient.id}}")
    }.should_not change(Mention, :count)
  end

  it "creates a mention from a splash's comment field" do
    author    = create(User).with_required_info!
    recipient = create(User).following([author]).with_required_info!
    splash    = create(Splash).
      track(create!(Track)).
      user(author).
      comment!("A comment mentioning @{#{recipient.id}}")

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
      comment!("A comment to @{#{recipient2.id}}
                mentioning @{#{recipient1.id}}")

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
end
