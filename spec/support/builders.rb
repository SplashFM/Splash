user_seq = 0

Bricks do
  builder Track do
    title  'Turn of the century'
    album  'Going for the one'
    ~performers.name('Yes')

    trait :with_genre do |name|
      genres.name(name)
    end

    trait :with_performer do |name|
      performers.clear

      ~performers.name(name)
    end
  end

  builder User do
    email        { "user#{user_seq}@mojotech.com" }
    password     'testing'
    confirmed_at 1.day.ago

    trait :with_required_info do
      name "Mojo User #{user_seq}"
    end

    trait :with_name do |n|
      email n.strip.downcase.gsub(/\s+/, '.') + "@userfactories.com"
      name  n
    end

    after :clone do
      user_seq += 1
    end
  end
end
