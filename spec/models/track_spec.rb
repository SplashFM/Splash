require 'spec_helper'

describe Track, :adapter => :postgresql do
  describe "searching", :adapter => :postgresql do
    it "is found by title" do
      create(Track).title!('Close to the edge')

      Track.with_text('Close to the edge').should have(1).result
    end

    it "is found by artist" do
      create(Track).artist!('Yes')

      Track.with_text('Yes').should have(1).result
    end

    it "is found by album" do
      create(Track).album!('Relayer')

      Track.with_text('Relayer').should have(1).result
    end

    it "may not be found" do
      create(Track).
        title('And you and I').
        album('Close to the edge').
        artist!('Yes')

      Track.with_text('Fragile').should be_empty
    end
  end

  it "always has an album art url" do
    subject.album_art_url.should == Track::DEFAULT_ALBUM_ART_URL
  end

  it "returns the album art url when it is set" do
    Track.new(:album_art_url => "url").album_art_url.should == "url"
  end

  it "validates music file types" do
    yes = Rack::Test::UploadedFile.new(file("the_vines_get_free.mp3"),
                                       'audio/mpeg')
    no  = Rack::Test::UploadedFile.new(__FILE__, "text/plain")

    build(Track).data!(no).should_not be_valid
    build(Track).data!(yes).should be_valid
  end
end
