if ! Rails.env.production? || ENV['FORCE_SEED'] == '1'
  Artist.seed :name do |g|
    g.name = 'Yes'
  end

  Artist.seed :name do |g|
    g.name = 'Nirvana'
  end
end
