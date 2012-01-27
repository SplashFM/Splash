class FriendsController < ApplicationController
  def index
    token   = current_user.social_connection('facebook').token
    friends = FbGraph::User.me(token).friends

    @users  = User.with_social_connection('facebook', friends.map(&:identifier))
  end
end
