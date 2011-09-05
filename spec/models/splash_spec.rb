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
end
