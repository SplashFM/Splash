require 'spec_helper'
require 'song_file'

describe SongFile do
  context "with mp3" do
    subject { SongFile.new(file("the_vines_get_free.mp3")) }

    it "skips transcoding when the default format is requested" do
      dont_allow(subject).transcode

      subject.path.should == file("the_vines_get_free.mp3")
    end

    it "raises an error when it can't determine the format" do
      lambda { SongFile.new("blah") }.should raise_error(SongFile::UnknownFormat)
    end
  end

  context "with m4a" do
    subject { SongFile.new(file("sky_sailing_steady_as_she_goes.m4a")) }

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
