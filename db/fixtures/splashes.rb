require File.dirname(__FILE__) + '/db/fixtures/users.rb'
require File.dirname(__FILE__) + '/db/fixtures/tracks.rb'

Splash.seed(:user_id, :track_id) { |s|
  s.user_id  = User.find_by_email('jack.close@mojotech.com').id
  s.track_id = Track.find_by_title('Close to the edge').id
}
