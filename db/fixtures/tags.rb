if ! Rails.env.production? || ENV['FORCE_SEED'] == '1'
  ActsAsTaggableOn::Tag.seed :name do |t|
    t.name = 'grunge'
  end

  ActsAsTaggableOn::Tag.seed :name do |t|
    t.name = 'progressive rock'
  end

  ActsAsTaggableOn::Tag.seed :name do |t|
    t.name = 'pop'
  end

  ActsAsTaggableOn::Tag.seed :name do |t|
    t.name = 'rock'
  end

  ActsAsTaggableOn::Tag.seed :name do |t|
    t.name = 'folk'
  end

  ActsAsTaggableOn::Tag.seed :name do |t|
    t.name = 'r&b'
  end
end
