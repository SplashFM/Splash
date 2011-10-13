require 'spec_helper'

describe Event do
  let(:user)  { create!(User) }
  let(:track) { create!(Track) }

  it "finds a splash filtered by track genre" do
    g = create(Genre).name!("Rock")
    t = create(Track).genres!([g])
    s = Splash.create!(:track => t, :user => user)

    Event.for(user, nil, :genre => [g.id]).should == [s]
  end

  it "finds no splash filtered by track genre if one doesn't exist" do
    g1 = create(Genre).name!("Rock")
    g2 = create(Genre).name!("Folk")
    t  = create(Track).genres!([g1])
    s  = Splash.create!(:track => t, :user => user)

    Event.for(user, nil, :genre => [g2.id]).should be_empty
  end

  it "finds a splash filtered by performer" do
    t = create(Track).performers!("Yes")

    s = Splash.create!(:track => t, :user => user)

    Event.for(user, nil, :artist => ["Yes"]).should == [s]
  end

  it "finds no splash filtered by performer if one doesn't exist" do
    t  = create(Track).performers!(["Yes"])
    s  = Splash.create!(:track => t, :user => user)

    Event.for(user, nil, :artist => ["Emerson, Lake & Palmer"]).should be_empty
  end

  it "finds all events when passed no filters" do
    s = Splash.create!(:track => track, :user => user)

    Event.for(user).should == [s]
  end
end
