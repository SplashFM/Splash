if ! Rails.env.production? || ENV['FORCE_SEED'] == '1'
  UndiscoveredTrack.seed :title do |s|
    s.title         = 'Close to the edge'
    s.albums        = [Album.find_by_name('Close to the edge')]
    s.performers    = [Artist.find_by_name('Yes')]
    s.album_art_url = 'http://userserve-ak.last.fm/serve/300x300/12636493.jpg'
    s.genres        = [Genre.find_by_name("Progressive rock")]
  end

  UndiscoveredTrack.seed :title do |s|
    s.title         = 'And you and I'
    s.albums        = [Album.find_by_name('Close to the edge')]
    s.performers    = [Artist.find_by_name('Yes')]
    s.album_art_url = 'http://userserve-ak.last.fm/serve/300x300/12636493.jpg'
    s.genres        = [Genre.find_by_name("Progressive rock")]
  end

  UndiscoveredTrack.seed :title do |s|
    s.title         = 'Siberian Kathru'
    s.albums        = [Album.find_by_name('Close to the edge')]
    s.performers    = [Artist.find_by_name('Yes')]
    s.album_art_url = 'http://userserve-ak.last.fm/serve/300x300/12636493.jpg'
    s.genres        = [Genre.find_by_name("Progressive rock")]
  end

  DiscoveredTrack.seed :title do |s|
    s.title            = 'Smells like Teen Spirit'
    s.albums           = [Album.find_by_name('Nevermind')]
    s.performers       = [Artist.find_by_name('Nirvana')]
    s.purchase_url_raw = "http://itunes.apple.com/us/album/smells-like-teen-spirit/id462548998?i=462549028&uo=4"
    s.album_art_url    = "http://a5.mzstatic.com/us/r1000/032/Features/4b/c4/cb/dj.mjhyndcl.100x100-75.jpg"
    s.genres        = [Genre.find_by_name("Grunge")]
  end
end
