require 'spec_helper'
require 'song_file'

describe SongFile do
  context "with mp3" do
    subject { SongFile.new(file("shot_clock_avicii_remix.mp3")) }

    it "reads the file metadata (ID3v2)" do
      subject.title.should  == "Shot Clock (Avicii Remix)"
      subject.album.should  == "www.GoodMusicAllDay.com"
      subject.artist.should == "Aer"
      subject.artwork.should be_a(File)
      subject.artwork.length.should_not be_zero
    end

    it "reads the file metadata (ID3v1)" do
      subject = SongFile.new(file("the_vines_get_free.mp3"))

      subject.title.should  == "Get Free"
      subject.album.should  == "Highly Evolved"
      subject.artist.should == "The Vines"
    end

    it "skips transcoding when the default format is requested" do
      dont_allow(subject).transcode

      subject.path.should == file("shot_clock_avicii_remix.mp3")
    end

    it "raises an error when it can't determine the format" do
      lambda { SongFile.new("blah") }.should raise_error(SongFile::UnknownFormat)
    end
  end

  context "with m4a" do
    subject { SongFile.new(file("sky_sailing_steady_as_she_goes.m4a")) }

    it "reads the file metadata" do
      subject.title.should  == "Steady As She Goes"
      subject.album.should  == "An Airplane Carried Me to Bed"
      subject.artist.should == "Sky Sailing"
      subject.artwork.should be_nil
    end
  end
end
