require "#{Rails.root}/db/fixtures/users.rb"

Relationship.seed(:follower_id, :followed_id) { |r|
  r.follower_id = User.find_by_email('user@mojotech.com').id
  r.followed_id = User.find_by_email('jack.close@mojotech.com').id
}

Relationship.seed(:follower_id, :followed_id) { |r|
  r.follower_id = User.find_by_email('jack.close@mojotech.com').id
  r.followed_id = User.find_by_email('jack.johnson@mojotech.com').id
}
