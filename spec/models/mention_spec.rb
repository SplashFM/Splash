require 'spec_helper'

describe Mention do
  it "creates no mention if the recipient is not following the author" do
    author    = create(User).with_required_info!
    recipient = create(User).with_required_info!

    lambda {
      create(Comment).
        author(author).
        body!("A comment mentioning @#{recipient.nickname}")
    }.should_not change(Mention, :count)
  end

  it "creates a mention from a splash's comment field" do
    author    = create(User).with_required_info!
    recipient = create(User).following([author]).with_required_info!
    splash    = create(Comment).
      author(author).
      body!("A comment mentioning @#{recipient.nickname}")

    mention = Mention.first

    mention.notified.should == recipient
    mention.notifier.should == author
    mention.target.should   == splash
  end

  it "creates many mentions from a splash's comment field" do
    author     = create(User).with_required_info!
    recipient1 = create(User).following([author]).with_required_info!
    recipient2 = create(User).following([author]).with_required_info!
    splash     = create(Comment).
      author(author).
      body!("A comment to @#{recipient2.nickname}
             mentioning @#{recipient1.nickname}")

    mentions     = Mention.all
    recipients   = mentions.map(&:notified)
    authors      = mentions.map(&:notifier).uniq
    mentionables = mentions.map(&:target).uniq

    recipients.should include(recipient1)
    recipients.should include(recipient2)

    authors.should      == [author]
    mentionables.should == [splash]
  end
end
