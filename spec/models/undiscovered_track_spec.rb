require 'spec_helper'

describe UndiscoveredTrack, :adapter => :postgresql do
  it "validates music file types" do
    pending

    yes = Rack::Test::UploadedFile.new(file("the_vines_get_free.mp3"),
                                       'audio/mpeg')
    no  = Rack::Test::UploadedFile.new(__FILE__, "text/plain")

    build(UndiscoveredTrack).data!(no).should_not be_valid
    build(UndiscoveredTrack).data!(yes).should be_valid
  end

  it "fails if no performer is present" do
    t = build(UndiscoveredTrack).performers!([])

    t.should be_invalid
    t.errors[:performers].should \
      include(I18n.t('activerecord.errors.messages.invalid'))
  end

  describe "fails if taken" do
    it "disregards case"

    it "with a single artist" do
      title     = "Steady As She Goes"
      performer = "Sky Sailing"
      create(Track).title(title).with_performer!(performer)

      t = UndiscoveredTrack.new(:title      => title,
                                :performers => [performer])

      t.should be_invalid
      t.should be_taken
    end

    it "with multiple artists" do
      title = "Steady As She Goes"
      p1    = "Sky Sailing"
      p2    = "Sky Sailing 2"
      create(Track).title(title).performers!([p2, p1])

      t = UndiscoveredTrack.new(:title      => title,
                                :performers => [p1, p2])

      t.should be_invalid
      t.should be_taken
    end
  end

  it "extracts metadata from the file" do
    f = Rack::Test::UploadedFile.new(file("shot_clock_avicii_remix.mp3"),
                                     'audio/mpeg')

    t = create(UndiscoveredTrack).data!(f)

    t.title.should      == "Shot Clock (Avicii Remix)"
    t.albums.should     == ["www.GoodMusicAllDay.com"]
    t.performers.should == ["Aer"]
  end
end
