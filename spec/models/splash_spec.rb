require 'spec_helper'

describe Splash do
  let(:user)  { create!(User) }
  let(:track) { create!(Track) }

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
end
