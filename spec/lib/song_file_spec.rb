require 'spec_helper'
require 'song_file'

describe SongFile do
  context "with mp3" do
    subject { SongFile.new(file("shot_clock_avicii_remix.mp3")) }

    it "reads the file metadata" do
      subject.title.should  == "Shot Clock (Avicii Remix)"
      subject.album.should  == "www.GoodMusicAllDay.com"
      subject.artist.should == "Aer"
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
    end

    it "transcodes to mp3" do
      mp3 = subject.path(:mp3)

      mp3.should =~ /sky_sailing_steady_as_she_goes.+\.mp3$/
      File.exists?(mp3).should be_true
    end

    it "raises an error when the transcoding fails" do
      stub(subject).`(anything) { # `
        system("false")

        "noes!"
      }

      lambda { subject.path(:mp3) }.
        should raise_error(SongFile::TranscodeError, "noes!")
    end
  end
end
