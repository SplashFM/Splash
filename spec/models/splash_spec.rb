require 'spec_helper'

describe Splash do
  let(:user)  { create!(User) }
  let(:track) { create!(Track) }

  before do
    Track.reset_splash_counts
  end

  it "splashes a song that the user hasn't splashed yet" do
    Splash.create!(:track => track, :user => user)
  end

  it "refuses to splash a song that the user already splashed" do
    Splash.create!(:track => track, :user => user)

    lambda { Splash.create!(:track => track, :user => user) }.
      should raise_error(ActiveRecord::RecordInvalid)
  end

  it "finds the splash for the given track and user" do
    s = Splash.create!(:track => track, :user => user)

    Splash.should be_for(user, track)
  end

  it "increments a track's splash count" do
    t = create!(Track)

    lambda {
      create(Splash).track(t).user!(user)
    }.should change(t, :splash_count).by(1)
  end

  describe "resplashing" do
    before do
      User.reset_ripple_counts
    end

    it "assigns a ripple to each parent splash owner" do
      t  = create!(Track)
      s1 = create(Splash).track(t).user!(create!(User))
      s2 = create(Splash).track(t).user(create!(User)).parent!(s1)
      s3 = create(Splash).track(t).user(create!(User)).parent!(s2)

      s1.user.ripple_count.should == 2
      s2.user.ripple_count.should == 1
      s3.user.ripple_count.should == 0
    end
  end
end
