require 'spec_helper'

describe Track, :adapter => :postgresql do
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
