class FriendsController < ApplicationController
  def index
    token   = current_user.social_connection('facebook').token
    friends = FbGraph::User.me(token).friends

    users = User.
      with_social_connection('facebook', friends.map(&:identifier)).
      by_score

    rels = current_user.relationships.with_following(users.map(&:id))
    relh = Hash[*rels.map { |r| [r.followed_id, r] }.flatten]

    @users = users.map { |u|
      j = u.as_json

      j[:relationship] = (relh[u.id] ||
                          {:follower_id => current_user.id,
                           :followed_id => u.id}).as_json

      j
    }
  end
end
