Bricks do
  builder Track do
    title  'Turn of the century'
    album  'Going for the one'
    artist 'Yes'
  end

  builder User do
    email        'user@mojotech.com'
    password     'testing'
    confirmed_at 1.day.ago

    trait :with_name do |n|
      email n.strip.downcase.gsub(/\s+/, '.') + "@userfactories.com"
      name  n
    end
  end
end
