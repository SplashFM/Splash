require 'spec_helper'

describe UndiscoveredTrack, :adapter => :postgresql do
  it "validates music file types" do
    yes = Rack::Test::UploadedFile.new(file("the_vines_get_free.mp3"),
                                       'audio/mpeg')
    no  = Rack::Test::UploadedFile.new(__FILE__, "text/plain")

    build(UndiscoveredTrack).data!(no).should_not be_valid
    build(UndiscoveredTrack).data!(yes).should be_valid
  end
end
