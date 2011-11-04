require File.dirname(__FILE__) + '/db/fixtures/users.rb'
require File.dirname(__FILE__) + '/db/fixtures/tracks.rb'

Splash.seed(:user_id, :track_id) { |s|
  s.user_id  = User.find_by_email('jack.close@mojotech.com').id
  s.track_id = Track.find_by_title('Close to the edge').id
}

u = User.find_by_email('user@mojotech.com')

1.upto(20) { |i|
  Splash.seed(:user_id, :track_id) { |s|
    s.user_id  = u.id
    s.track_id = Track.find_by_title("Track #{i}").id
  }
}
