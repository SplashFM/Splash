user_seq  = 0
track_seq = 0
social_uid_seq   = '123456789'
social_token_seq = '123'

fpath       = File.join(Rails.root, %w(spec support files avatar.jpg))
temp_avatar = Tempfile.new('avatar') and temp_avatar.write IO.read(fpath)

Bricks do
  builder Relationship do
    follower.with_required_info!
    followed.with_required_info!
  end

  builder Comment do
    splash
    body "This is a comment!"
  end

  builder Splash do
    track
    user

    trait :mention do |*users|
      mentions = "@" << users.map(&:nickname).join(" @")

      comment "Hey, I'm mentioning #{mentions}!"
    end

    trait :with_comment_by do |user|
      comments.author(user)
    end

    trait :with_parent do |p|
      track  p.track
      parent p
    end
  end

  builder Track do
    title  { "Turn of the century #{track_seq}" }
    albums ["Going for the one"]
    performers ["Yes"]
    popularity_rank 999

    trait :with_performer do |name|
      performers [name]
    end

    after :clone do
      track_seq  += 1
    end
  end

  builder User do
    email        { "user#{user_seq}@mojotech.com" }
    password     'testing'
    confirmed_at 1.day.ago
    name         { "Mojo User #{user_seq}" }
    avatar       temp_avatar

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

  builder SocialConnection do
    user
    uid   { social_uid_seq }
    token { social_token_seq }

    before :save do
      social_uid_seq.succ!
      social_token_seq.succ!
    end

    after :clone do
      social_uid_seq.succ!
      social_token_seq.succ!
    end
  end
end
