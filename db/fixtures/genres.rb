if ! Rails.env.production? || ENV['FORCE_SEED'] == '1'
  Genre.seed :name do |g|
    g.name = 'Grunge'
  end

  Genre.seed :name do |g|
    g.name = 'Progressive rock'
  end

  Genre.seed :name do |g|
    g.name = 'Pop'
  end

  Genre.seed :name do |g|
    g.name = 'Rock'
  end

  Genre.seed :name do |g|
    g.name = 'Folk'
  end

  Genre.seed :name do |g|
    g.name = 'R&B'
  end
end
