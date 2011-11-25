user_seq  = 0
track_seq = 0

Bricks do
  builder Artist do
    name 'Yes'
  end

  builder Album do
    name 'Going for the one'
  end

  builder Relationship do
    follower.with_required_info!
    followed.with_required_info!
  end

  builder Comment do
    body "This is a comment!"
  end

  builder Splash do
    track
    user

    trait :mention do |user|
      comment "Hey, I'm mentioning @#{user.nickname}!"
    end

    trait :with_comment_by do |user|
      comments.author(user)
    end
  end

  builder Track do
    title  { "Turn of the century #{track_seq}" }
    albums ["Going for the one"]
    performers ["Yes"]

    trait :with_performer do |name|
      performers [name]
    end

    after :clone do
      track_seq  += 1
    end
  end

  builder User do
    email        { "user#{user_seq}@mojotech.com" }
    nickname     { "User#{user_seq}"}
    password     'testing'
    confirmed_at 1.day.ago

    trait :with_required_info do
      name "Mojo User #{user_seq}"
    end

    trait :with_name do |n|
      email n.strip.downcase.gsub(/\s+/, '.') + "@userfactories.com"
      name  n
    end

    before :save do
      user_seq  += 1
    end
  end
end
