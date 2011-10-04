require 'spec_helper'

describe User, :adapter => :postgresql do
  it "is found by name" do
    create(User).with_name!('Jack Johnson')

    User.with_text('Jack Johnson').should have(1).result
  end

  it "may not be found" do
    create(User).with_name!('Sigmund Freud')

    User.with_text('Jack Johnson').should be_empty
  end

  it "should follow another user" do
    @followed = create(User).with_name!('Jack Johnson')
    @follower = create(User).with_name!('Sigmund Freud')

    @follower.follow(@followed)
    @follower.should be_following(@followed)
  end

  it "should unfollow another user" do
    @followed = create(User).with_name!('Jack Johnson')
    @ex_follower = create(User).with_name!('Sigmund Freud')
    @ex_follower.follow(@followed)
    @ex_follower.unfollow(@followed)
    @ex_follower.should_not be_following(@followed)
  end
end
