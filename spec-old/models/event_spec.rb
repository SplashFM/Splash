require 'spec_helper'

describe Event do
  let(:user)   { create!(User) }
  let(:friend) { create(User).followers!([user]) }

  [
   ['comments', :other, Comment],
   ['relationships', :other, Relationship],
   ['splashes', :splashes, Splash],
  ].each { |(label, filter, klass)|
    it "includes #{label}" do
      create!(klass)

      events = Event.scope_by(filter => 1)
      events.should have(1).item
      events.each { |e| e.should be_an_instance_of(klass) }
    end

    it "filters out #{label}" do
      create!(klass)

      Event.scope_by({}).should be_empty
    end
  }

  describe "scoping to user" do
    let(:other) { create!(User) }

    it "filters out unrelated comments" do
      create(Splash).with_comment_by!(other)

      Event.scope_by(:user => user.id, :splashes => 1, :other => 1).
        should be_empty
    end
  end

  describe "update counts" do
    it "updates the counter on friend splash" do
      create(Splash).user!(friend) and updates.should == 1
    end

    it "does not update the counter on unrelated splash" do
      create!(Splash) and updates.should == 0
    end

    it "updates the counter with each update" do
      create(Splash).user!(friend) and updates.should == 1
      create(Splash).user!(friend) and updates.should == 2
    end

    it "returns updates only since last update" do
      Timecop.freeze(2.hours.ago) { create(Splash).user! friend }

      create(Splash).user!(friend) and updates.should == 1
    end

    def updates(last_update = 1.hour.ago)
      Event.scope_by(:count          => 1,
                     :follower       => user.id,
                     :last_update_at => last_update.iso8601,
                     :splashes       => 1,
                     :user           => user.id)
    end
  end

  describe "mentions" do
    before do
      create(Splash).user(friend).mention!(user)
    end

    it "includes mentions" do
      Event.scope_by(:user => user.id, :mentions => 1).should have(1).item
    end

    it "includes a mention only once" do
      create(Comment).author(friend).splash!(Splash.first)

      Event.scope_by(:user => user.id, :mentions => 1).should have(1).item
    end

    it "filters out mentions" do
      Event.scope_by(:user => user.id).should be_empty
    end
  end
end
