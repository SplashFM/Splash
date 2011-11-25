require 'spec_helper'

describe Event do
  let(:user)   { create!(User) }
  let(:friend) { create!(User) }

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

  describe "mentions" do
    before do
      user.follow friend

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
