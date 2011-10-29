if ! Rails.env.production? || ENV['FORCE_SEED'] == '1'
  DiscoveredTrack.seed :title do |s|
    s.title         = 'Close to the edge'
    s.albums        = ['Close to the edge']
    s.performers    = ['Yes']
    s.artwork_url = 'http://userserve-ak.last.fm/serve/300x300/12636493.jpg'
    s.genres        = [Genre.find_by_name("Progressive rock")]
  end

  DiscoveredTrack.seed :title do |s|
    s.title         = 'And you and I'
    s.albums        = ['Close to the edge']
    s.performers    = ['Yes']
    s.artwork_url = 'http://userserve-ak.last.fm/serve/300x300/12636493.jpg'
    s.genres        = [Genre.find_by_name("Progressive rock")]
  end

  DiscoveredTrack.seed :title do |s|
    s.title         = 'Siberian Kathru'
    s.albums        = ['Close to the edge']
    s.performers    = ['Yes']
    s.artwork_url = 'http://userserve-ak.last.fm/serve/300x300/12636493.jpg'
    s.genres        = [Genre.find_by_name("Progressive rock")]
  end

  DiscoveredTrack.seed :title do |s|
    s.title            = 'Smells like Teen Spirit'
    s.albums           = ['Nevermind']
    s.performers       = ['Nirvana']
    s.purchase_url_raw = "http://itunes.apple.com/us/album/smells-like-teen-spirit/id462548998?i=462549028&uo=4"
    s.preview_url      = "http://a589.phobos.apple.com/us/r1000/091/Music/b1/f3/01/mzm.jgkbtcua.aac.p.m4a"
    s.artwork_url    = "http://a5.mzstatic.com/us/r1000/032/Features/4b/c4/cb/dj.mjhyndcl.100x100-75.jpg"
    s.genres           = [Genre.find_by_name("Grunge")]
  end
end
