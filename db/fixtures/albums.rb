if ! Rails.env.production? || ENV['FORCE_SEED'] == '1'
  Album.seed :name do |g|
    g.name = 'Close to the edge'
  end

  Album.seed :name do |g|
    g.name = 'Nevermind'
  end
end
