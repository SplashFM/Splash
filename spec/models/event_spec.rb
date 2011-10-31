require 'spec_helper'

describe Event do
  let(:user)  { create!(User) }
  let(:track) { create!(Track) }

  it "finds a splash filtered by track tag" do
    g = create(ActsAsTaggableOn::Tag).name!("Rock")
    t = create(Track).tag_list!(["Rock"])
    s = Splash.create!(:track => t, :user => user)

    Event.for(user, nil, :tag => [g.id]).should == [s]
  end

  it "finds no splash filtered by track tag if one doesn't exist" do
    t1 = create(ActsAsTaggableOn::Tag).name!("Rock")
    t2 = create(ActsAsTaggableOn::Tag).name!("Folk")
    t  = create(Track).tag_list!(["Rock"])
    s  = Splash.create!(:track => t, :user => user)

    Event.for(user, nil, :tag => [t2.id]).should be_empty
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
