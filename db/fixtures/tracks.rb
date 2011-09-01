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
end
