require 'spec_helper'

describe Mention do
  it "creates a mention from a splash's comment field" do
    recipient = create(User).with_required_info!
    author    = create!(User)
    splash    = create(Splash).
      track(create!(Track)).
      user(author).
      comment!("A comment mentioning @{#{recipient.id}}")

    mention = Mention.first

    mention.notified.should == recipient
    mention.notifier.should == author
    mention.target.should   == splash
  end
end
