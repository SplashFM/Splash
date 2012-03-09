require 'spec_helper'

describe Track, :adapter => :postgresql do
  it "stores performers given a list" do
    ps = %w(P2 P1)
    t  = create(Track).performers!(ps)

    t.reload.performers.should == ps.reverse
  end

  it "stores performers given a string" do
    t  = create(Track).performers!("P2;;P1")

    t.reload.performers.should == %w(P1 P2)
  end

  it "stores albums given a list" do
    as = %w(A2 A1)
    t  = create(Track).albums!(as)

    t.reload.albums.should == as.reverse
  end

  it "stores albums given a string" do
    t  = create(Track).albums!("A2;;A1")

    t.reload.albums.should == %w(A1 A2)
  end

  describe "searching", :adapter => :postgresql do
    it "finds tracks by title" do
      create(Track).title!('Close to the edge')

      Track.with_text('Close to the edge').should have(1).result
    end

    it "finds tracks by performer" do
      create(Track).with_performer!('Yes')

      Track.with_text('Yes').should have(1).result
    end

    it "finds nothing if there's nothing to find" do
      create(Track).
        title('And you and I').
        albums(['Close to the edge']).
        with_performer!('Yes')

      Track.with_text('Fragile').should be_empty
    end

    it "allows finding popular tracks only" do
      popular = create(DiscoveredTrack).
        albums(['Close to the edge']).
        popularity_rank(999).
        title!('And you And I')
      unpopular = create(DiscoveredTrack).
        albums(['Close to the edge']).
        popularity_rank(1000).
        title!('Siberian Kathru')

      results = Track.with_text('Close to the edge').popular

      results.should include(popular)
      results.should_not include(unpopular)
    end
  end

  it "always has an artwork url" do
    subject.artwork_url.should == Track::DEFAULT_ARTWORK_URL
  end

  it "returns the artwork url when it is set" do
    Track.new(:artwork_url => "url").artwork_url.should == "url"
  end

  it "sorts top splashed songs" do
    Track.reset_splash_counts

    tracks = []

    1.upto(5) { |i|
      tracks << [(t = create!(Track)).id, i]

      i.times { create(Splash).track(t).user!(create!(User)) }
    }

    Track.top_splashed(1, 5).map { |t| [t.id, t.splash_count] }.
      should == tracks.reverse
  end

  it "recalculates splash counts" do
    tracks = 1.upto(3).map { |i|
      create!(Track).tap { |t| i.times { create(Splash).track!(t) } }
    }

    Track.reset_splash_counts
    Track.recompute_splash_counts

    Track.top_splashed(1, 5).should == tracks.reverse
  end
end
