require 'spec_helper'

describe Track, :adapter => :postgresql do
  describe "searching", :adapter => :postgresql do
    it "is found by title" do
      create(Track).title!('Close to the edge')

      Track.with_text('Close to the edge').should have(1).result
    end

    it "is found by performer" do
      create(Track).with_performer!('Yes')

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
        with_performer!('Yes')

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

  it "fails if no performer is present" do
    t = build!(Track)
    t.performers = []

    t.should be_invalid
    t.errors[:performer].should \
      include(I18n.t('activerecord.errors.messages.invalid'))
  end

  describe "fails if taken" do
    it "disregards case"

    it "with a single artist" do
      title     = "Steady As She Goes"
      performer = "Sky Sailing"
      create(Track).title(title).with_performer!(performer)

      t = Track.new(:title      => title,
                    :performers => [create(Artist).name?(performer)])

      t.should be_taken
    end

    it "with multiple artists" do
      title = "Steady As She Goes"
      p1    = create(Artist).name!("Sky Sailing")
      p2    = create(Artist).name!("Sky Sailing 2")
      create(Track).title(title).performers!([p2, p1])

      t = Track.new(:title      => title,
                    :performers => [p1, p2])

      t.should be_taken
    end
  end
end
