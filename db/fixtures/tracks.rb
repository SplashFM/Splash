if ! Rails.env.production? || ENV['FORCE_SEED'] == '1'
  UndiscoveredTrack.seed :title, :album do |s|
    s.title         = 'Close to the edge'
    s.album         = 'Close to the edge'
    s.performers    = [Artist.find_by_name('Yes')]
    s.album_art_url = 'http://userserve-ak.last.fm/serve/300x300/12636493.jpg'
    s.genres        = [Genre.find_by_name("Progressive rock")]
  end

  UndiscoveredTrack.seed :title, :album do |s|
    s.title         = 'And you and I'
    s.album         = 'Close to the edge'
    s.performers    = [Artist.find_by_name('Yes')]
    s.album_art_url = 'http://userserve-ak.last.fm/serve/300x300/12636493.jpg'
    s.genres        = [Genre.find_by_name("Progressive rock")]
  end

  UndiscoveredTrack.seed :title, :album do |s|
    s.title         = 'Siberian Kathru'
    s.album         = 'Close to the edge'
    s.performers    = [Artist.find_by_name('Yes')]
    s.album_art_url = 'http://userserve-ak.last.fm/serve/300x300/12636493.jpg'
    s.genres        = [Genre.find_by_name("Progressive rock")]
  end

  DiscoveredTrack.seed :title, :album do |s|
    s.title            = 'Smells like Teen Spirit'
    s.album            = 'Nevermind'
    s.performers       = [Artist.find_by_name('Nirvana')]
    s.purchase_url_raw = "http://itunes.apple.com/us/album/smells-like-teen-spirit/id462548998?i=462549028&uo=4"
    s.album_art_url    = "http://a5.mzstatic.com/us/r1000/032/Features/4b/c4/cb/dj.mjhyndcl.100x100-75.jpg"
    s.genres        = [Genre.find_by_name("Grunge")]
  end

  1.upto(30) { |i|
    UndiscoveredTrack.seed :title, :album do |s|
      s.title  = "Track #{i}"
      s.album  = "Album"
    end
  }
end
