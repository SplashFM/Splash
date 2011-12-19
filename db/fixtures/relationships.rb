require "#{Rails.root}/db/fixtures/users.rb"

Relationship.seed(:follower_id, :followed_id) { |r|
  r.follower_id = User.find_by_email('user@mojotech.com').id
  r.followed_id = User.find_by_email('jack.close@mojotech.com').id
}

Relationship.seed(:follower_id, :followed_id) { |r|
  r.follower_id = User.find_by_email('jack.close@mojotech.com').id
  r.followed_id = User.find_by_email('jack.johnson@mojotech.com').id
}

mojo_user = User.find_by_email('user@mojotech.com')
close     = User.find_by_email('jack.close@mojotech.com')

1.upto(30) do |i|
  u = User.find_by_name("Mojo User #{i}")

  Relationship.seed(:follower_id, :followed_id) { |r|
    r.follower_id = u.id
    r.followed_id = mojo_user.id
  }

  Relationship.seed(:follower_id, :followed_id) { |r|
    r.follower_id = close.id
    r.followed_id = u.id
  }
end

# weird
mojo_user.suggest_users

31.upto(60) do |i|
  u = User.find_by_name("Mojo User #{i}")

  Relationship.seed(:follower_id, :followed_id) { |r|
    r.follower_id = mojo_user.id
    r.followed_id = u.id
  }
end
