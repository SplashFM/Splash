unless Rails.env.production?
  Track.seed :title, :album, :artist do |s|
    s.title  = 'Close to the edge'
    s.album  = 'Close to the edge'
    s.artist = 'Yes'
  end

  Track.seed :title, :album, :artist do |s|
    s.title  = 'And you and I'
    s.album  = 'Close to the edge'
    s.artist = 'Yes'
  end

  Track.seed :title, :album, :artist do |s|
    s.title  = 'Siberian Kathru'
    s.album  = 'Close to the edge'
    s.artist = 'Yes'
  end

  Track.seed :title, :album, :artist do |s|
    s.title  = 'Smells like Teen Spirit'
    s.album  = 'Nevermind'
    s.artist = 'Nirvana'
    s.purchase_url_raw = "http://itunes.apple.com/us/album/smells-like-teen-spirit/id462548998?i=462549028&uo=4"
    s.source = 'itunes'
  end

  1.upto(30) { |i|
    Track.seed :title, :album, :artist do |s|
      s.title  = "Track #{i}"
      s.album  = "Album"
      s.artist = 'Artist'
    end
  }
end
