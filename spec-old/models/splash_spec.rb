require 'spec_helper'

describe Splash do
  let(:user)  { create!(User) }
  let(:track) { create!(Track) }

  before do
    Track.reset_splash_counts
    User.reset_splash_counts
    User.reset_ripple_counts
    User.reset_sorted_influence
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

  it "increments the user's splash count" do
    u = create!(User)

    lambda {
       create(Splash).track(create!(Track)).user!(u)
    }.should change(u, :splash_count).by(1)
  end

  it "freezes the splash hierarchy" do
    t  = create!(Track)
    s1 = create(Splash).track(t).user!(create!(User))
    s2 = create(Splash).track(t).user(create!(User)).parent!(s1)

    Splash.find(s2.id).user_path.should == [s1.id.to_s]
  end

  it "updates the user's influence rank" do
    u1 = create!(User)
    create(Splash).track(create!(Track)).user!(u1)

    u2 = create!(User)
    create(Splash).track(create!(Track)).user!(u2)
    create(Splash).track(create!(Track)).user!(u2)

    u2.influence_rank.should == 0
    u1.influence_rank.should == 1
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

  describe "ripple counts" do
    let(:s1) { create!(Splash) }
    let(:s2) { create(Splash).with_parent!(s1) }
    let(:s3) { create(Splash).with_parent!(s2) }

    before { s3 }

    it "allows 0 ripples" do
      s3.ripple_count.should == 0
    end

    it "calculate ripples for parent-child relationship" do
      s2.ripple_count.should == 1
    end

    it "takes the whole splash hierarchy into account" do
      s1.ripple_count.should == 2
    end
  end
end
