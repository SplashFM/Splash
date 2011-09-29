require 'spec_helper'

describe Track, :adapter => :postgresql do
  describe "searching", :adapter => :postgresql do
    it "is found by title" do
      create(Track).title!('Close to the edge')

      Track.filtered('Close to the edge').should have(1).result
    end

    it "is found by artist" do
      create(Track).artist!('Yes')

      Track.filtered('Yes').should have(1).result
    end

    it "is found by album" do
      create(Track).album!('Relayer')

      Track.filtered('Relayer').should have(1).result
    end

    it "may not be found" do
      create(Track).
        title('And you and I').
        album('Close to the edge').
        artist!('Yes')

      Track.filtered('Fragile').should be_empty
    end
  end

  it "always has an album art url" do
    subject.album_art_url.should == Track::DEFAULT_ALBUM_ART_URL
  end

  it "returns the album art url when it is set" do
    Track.new(:album_art_url => "url").album_art_url.should == "url"
  end
end
