require 'spec_helper'

describe User, :adapter => :postgresql do
  it "is found by name" do
    create(User).with_name!('Jack Johnson')

    User.with_text('Jack Johnson').should have(1).result
  end

  it "searched by name, accepts special characters" do
    create(User).email('jack@mojotech.com').
                 name!('Jack Johnson (parenthesis)')

    User.with_text('Jack Johnson (parenthesis)').should have(1).result
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

  it "starts with a splash score of 10 on account creation" do
    RedisRecord.reset_all

    create!(User).splash_score.should == 10
  end

  it "should start with no ripples" do
    create!(User).ripple_count.should == 0
  end

  describe "nicknames" do
    it "generates a nickname from the name" do
      create(User).name!('Adam Constantinides').nickname.
        should == 'adam_constantinides'
    end

    it "forbids creating nicknames with spaces" do
      lambda {
        create(User).
          name('Adam Constantinides').
          nickname!('Adam Constantinides')
      }.should raise_error(ActiveRecord::RecordInvalid)
    end
  end

  it "calculates the splash count from the DB" do
    user = create!(User)

    create(Splash).user!(user)
    create(Splash).user!(user)

    user.slow_splash_count.should == 2
  end

  describe "calculates ripple counts" do
    let(:u1) { create!(User) }
    let(:u2) { create!(User) }
    let(:u3) { create!(User) }

    let(:s1) { create(Splash).user!(u1) }
    let(:s2) { create(Splash).user(u2).with_parent!(s1) }
    let(:s3) { create(Splash).user(u3).with_parent!(s2) }

    before { s3 }

    it "allows 0 ripples" do
      u3.slow_ripple_count.should == 0
    end

    it "calculate ripples for parent-child relationship" do
      u2.slow_ripple_count.should == 1
    end

    it "takes the whole splash hierarchy into account" do
      u1.slow_ripple_count.should == 2
    end
  end

  it "recomputes the splash count for all users" do
    users = 1.upto(3).map { |i|
      create!(User).tap { |u| i.times { create(Splash).user!(u) } }
    }

    User.reset_splash_counts
    User.recompute_splash_counts

    User.sorted_by_splash_count(1, 5).should == users.reverse
  end

  it "recomputes the ripple count for all users" do
    u1 = create!(User)
    u2 = create!(User)
    u3 = create!(User)

    s3 = create(Splash).user!(u3)
    s2 = create(Splash).user(u2).with_parent!(s3)
    create(Splash).user(u1).with_parent!(s2)

    User.reset_ripple_counts
    User.recompute_ripple_counts

    User.sorted_by_ripple_count(1, 5).should == [u3, u2, u1]
  end

  describe "filtering" do
    let(:homer) { create(User).name!('Homer Simpson') }
    let(:bart)  { create(User).name('Bart Simpson').nickname!('bartman') }

    before { homer and bart }

    it "filters user by name" do
      User.filter('H').should == [User.find_by_name('Homer Simpson')]
    end

    it "filters user by nickname" do
      User.filter('bartm').should == [User.find_by_name('Bart Simpson')]
    end
  end
end
