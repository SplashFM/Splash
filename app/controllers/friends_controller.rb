class FriendsController < ApplicationController
  def index
    token   = current_user.social_connection('facebook').token
    friends = FbGraph::User.me(token).friends

    fsh   = Hash[*friends.map { |f| [f.identifier, f] }.flatten]
    users = User.
      with_social_connection('facebook', fsh.keys).
      by_score

    missing = fsh.keys - users.map { |u| u.social_connection('facebook').uid }

    rels = current_user.relationships.with_following(users.map(&:id))
    relh = Hash[*rels.map { |r| [r.followed_id, r] }.flatten]

    @users = users.map { |u|
      j = u.as_json

      j[:relationship] = (relh[u.id] ||
                          {:follower_id => current_user.id,
                           :followed_id => u.id}).as_json

      j
    } + friend_hashes(fsh.values_at(*missing))
  end

  private

  def friend_hashes(friends)
    friends.map { |f|
      {:name             => f.name,
       :avatar_micro_url => f.picture('square'),
       :origin           => 'facebook'}
    }
  end
end
